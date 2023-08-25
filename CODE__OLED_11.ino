#include "MAX30100_PulseOximeter.h"
#include "SH1106Wire.h"
#include "Adafruit_GFX.h"
#include <MPU6050.h>
#include <Wire.h>
#include "icon.c"
#include <ESP8266WiFi.h>
#include <WifiLocation.h>
#include <ESP8266HTTPClient.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"


#define REPORTING_PERIOD_MS 1000
#define FIREBASE_HOST "https://health-follower-default-rtdb.firebaseio.com"
#define FIREBASE_AUTH "hm0NzDfqxJGiImaY0UeziYVBZSkvoHCa0Z9JHbKS"

/* 2. Define the API Key */
#define API_KEY "AIzaSyAIEv8hV1kPfQUSsfOcl5fJ9AVhqMmieKs"

/* 3. Define the RTDB URL */
#define DATABASE_URL "https://health-follower-default-rtdb.firebaseio.com"

/* 4. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL "leong10a@gmail.com"
#define USER_PASSWORD "12345678"

// PulseOximeter is the higher level interface to the sensor
// it offers:
//  * beat detection reporting
//  * heart rate calculation
//  * SpO2 (oxidation level) calculation
PulseOximeter pox;

SH1106Wire display(0x3c, D2, D1);

//// Insert your network credentials
const char *ssid = "kem";  // Enter your WiFi Name
const char *password = "traangdaai";

// const char *ssid = "I Love Window 7";  // Enter your WiFi Name
// const char *password = "batlaailopdiutu";

const char *googleApiKey = "AIzaSyChC9UIOuaG602jxNMzTzHUQYvPFj6kWv0";

WifiLocation location(googleApiKey);

MPU6050 mpu;
//
//// Insert Firebase project API Key
//#define API_KEY "AIzaSyAIEv8hV1kPfQUSsfOcl5fJ9AVhqMmieKs"
//
//// Insert RTDB URLefine the RTDB URL */
//#define DATABASE_URL "https://health-follower-default-rtdb.firebaseio.com/"
//
////Define Firebase Data object
FirebaseData fbdo;
//
FirebaseAuth auth;
FirebaseConfig config;

String databasePath;
// Database child nodes
String heartPath = "/heartRate";
String spO2Path = "/spO2";
String fallPath = "/isTeNga";

// Id device ----------------> set up when upload code for device
// Use to update realtime data in firebase
String idDevice = "19129050";

// Variable to save USER UID
String uid;

// Parent Node (to be updated in every loop)
String parentPath;

FirebaseJson json;

// Timer variables (send new readings every three minutes)
unsigned long sendDataPrevMillis = 0;
unsigned long teNgaTime = 0;
unsigned long timerDelay = 180000;

uint32_t tsLastReport = 0;

bool isFirstCompile = true;
unsigned long last = 0;
bool isShowSplash = true;

int analogInPin = A0;
int sensorValue;           // Analog Output of Sensor
float calibration = 0.36;  // Check Battery voltage using multimeter & add/subtract the value
int bat_percentage;

//=============== BIẾN DÙNG CHO MPU6050, VUI LÒNG GIỮ NGUYÊN =====================
const int MPU_addr = 0x68;  // I2C address of the MPU-6050
int16_t AcX, AcY, AcZ, Tmp, GyX, GyY, GyZ;
float ax = 0, ay = 0, az = 0, gx = 0, gy = 0, gz = 0;
boolean fall = false;      //stores if a fall has occurred
boolean trigger1 = false;  //stores if first trigger (lower threshold) has occurred
boolean trigger2 = false;  //stores if second trigger (upper threshold) has occurred
boolean trigger3 = false;  //stores if third trigger (orientation change) has occurred
byte trigger1count = 0;    //stores the counts past since trigger 1 was set true
byte trigger2count = 0;    //stores the counts past since trigger 2 was set true
byte trigger3count = 0;    //stores the counts past since trigger 3 was set true
int angleChange = 0;


int buzzer = 12;
int button = 14;
// Temp var use to save button state
int temp = 0;
bool tadao = false;

bool isSetFB = true;
bool isChangeData = true;

/*================================================================================================
============KHU VUC TEST LAY MAU, VUI LONG KHONG HIEU CHINH=======================================
==================================================================================================
==================================================================================================*/
float ax_offset, ay_offset, az_offset;
int calibration_samples = 100;
float gx_offset, gy_offset, gz_offset, gx_scale, gy_scale, gz_scale;

void preprocessionMpu() {
  mpu.initialize();

  // Kiểm tra kết nối cảm biến
  Serial.println(mpu.testConnection() ? "MPU6050 connection successful" : "MPU6050 connection failed");

  ax_offset = 0;
  ay_offset = 0;
  az_offset = 0;

  gx_offset = 0;
  gy_offset = 0;
  gz_offset = 0;
  gx_scale = 1.0;  // Tỷ lệ chia cho gx
  gy_scale = 1.0;  // Tỷ lệ chia cho gy
  gz_scale = 1.0;  // Tỷ lệ chia cho gz

  for (int i = 0; i < calibration_samples; i++) {
    // Đọc dữ liệu gia tốc từ cảm biến MPU6050
    int16_t AcX, AcY, AcZ;
    mpu.getAcceleration(&AcX, &AcY, &AcZ);

    // Cộng dồn các giá trị đọc để tính trung bình
    ax_offset += AcX;
    ay_offset += AcY;
    az_offset += AcZ;

    // delay(10); // Đợi 10ms trước khi lấy mẫu tiếp theo

    int16_t GyX, GyY, GyZ;
    mpu.getRotation(&GyX, &GyY, &GyZ);

    // Cộng dồn các giá trị đọc để tính trung bình
    gx_offset += GyX;
    gy_offset += GyY;
    gz_offset += GyZ;
  }

  // Tính giá trị trung bình của offset
  ax_offset /= calibration_samples;
  ay_offset /= calibration_samples;
  az_offset /= calibration_samples;

  //============================ góc =============================

  // Tính giá trị trung bình của offset
  gx_offset /= calibration_samples;
  gy_offset /= calibration_samples;
  gz_offset /= calibration_samples;
}

void setupFirebase() {

  // config.signer.tokens.legacy_token = FIREBASE_AUTH;
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  config.database_url = DATABASE_URL;

  Firebase.reconnectWiFi(true);
  fbdo.setResponseSize(4096);
  config.token_status_callback = tokenStatusCallback;
  config.max_token_generation_retry = 5;
  Firebase.begin(&config, &auth);

    setClock();
  // Sau khi hàm setClock chạy xong
  location_t loc = location.getGeoFromWiFi();
    Firebase.RTDB.setString(&fbdo, idDevice + "/location/latitude", String(loc.lat, 7));
    Firebase.RTDB.setString(&fbdo, idDevice + "/location/longitude", String(loc.lon, 7));
  Serial.println(location.getSurroundingWiFiJson());
  Serial.println("Latitude: " + String(loc.lat, 7));
  Serial.println("Longitude: " + String(loc.lon, 7));
  Serial.println("Accuracy: " + String(loc.accuracy));
}

void setup_wifi() {
  Serial.begin(115200);
  Wire.begin();
  Wire.beginTransmission(MPU_addr);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0);     // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);
  Serial.println(ssid);
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  Serial.println("Setup done");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");  // print ... till not connected
  }
  Serial.println("");
  Serial.println("WiFi connected");
  WiFi.setAutoReconnect(true);
  WiFi.persistent(true);
  // Tạo delay chờ lấy dữ liệu vị trí
}


void setClock() {
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");

  Serial.print("Waiting for NTP time sync: ");
  time_t now = time(nullptr);
  while (now < 8 * 3600 * 2) {
    delay(500);
    Serial.print(".");
    now = time(nullptr);
  }
  struct tm timeinfo;
  gmtime_r(&now, &timeinfo);
  Serial.print("\n");
  Serial.print("Current time: ");
  Serial.print(asctime(&timeinfo));
}

WiFiEventHandler wifiConnectHandler;
WiFiEventHandler wifiDisconnectHandler;

void onWifiConnect(const WiFiEventStationModeGotIP &event) {
  Serial.println("Connected to Wi-Fi sucessfully.");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void onWifiDisconnect(const WiFiEventStationModeDisconnected &event) {
  Serial.println("Disconnected from Wi-Fi, trying to connect...");
  WiFi.disconnect();
  WiFi.begin(ssid, password);
}

void mpu_read() {
  Wire.beginTransmission(MPU_addr);
  Wire.write(0x3B);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_addr, 14, true);  // request a total of 14 registers
  AcX = Wire.read() << 8 | Wire.read();  // 0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)
  AcY = Wire.read() << 8 | Wire.read();  // 0x3D (ACCEL_YOUT_H) & 0x3E (ACCEL_YOUT_L)
  AcZ = Wire.read() << 8 | Wire.read();  // 0x3F (ACCEL_ZOUT_H) & 0x40 (ACCEL_ZOUT_L)
  Tmp = Wire.read() << 8 | Wire.read();  // 0x41 (TEMP_OUT_H) & 0x42 (TEMP_OUT_L)
  GyX = Wire.read() << 8 | Wire.read();  // 0x43 (GYRO_XOUT_H) & 0x44 (GYRO_XOUT_L)
  GyY = Wire.read() << 8 | Wire.read();  // 0x45 (GYRO_YOUT_H) & 0x46 (GYRO_YOUT_L)
  GyZ = Wire.read() << 8 | Wire.read();  // 0x47 (GYRO_ZOUT_H) & 0x48 (GYRO_ZOUT_L)
}

void setup_Max30100() {
  pox.begin();
  pox.update();
  // Initialize the PulseOximeter instance and register a beat-detected callback
  if (!pox.begin()) {
    Serial.println("FAILED");
    for (;;)
      ;
  } else {
    Serial.println("SUCCESS");
  }

  pox.setIRLedCurrent(MAX30100_LED_CURR_7_6MA);
  pox.setOnBeatDetectedCallback(onBeatDetected);
}

void onBeatDetected() {
  Serial.println("Beat!");
  Serial.print(Firebase.ready());
  if (Firebase.ready() && millis() - sendDataPrevMillis > 15000) {
    Serial.println("Here!");
    Firebase.RTDB.setString(&fbdo, idDevice + "/heartRate", String(pox.getHeartRate()));
    Firebase.RTDB.setString(&fbdo, idDevice + "/spO2", String(pox.getSpO2()));
    // pox.begin();
    // pox.update();
    sendDataPrevMillis = millis();
    isChangeData = true;
  }
}

void hien_thi() {
  if ((isFirstCompile || isShowSplashText()) && isShowSplash) {
    isFirstCompile = false;
    display.init();
    // display.flipScreenVertically();
    display.setFont(ArialMT_Plain_10);
    // display.setTextAlignment(TEXT_ALIGN_LEFT);
    display.clear();
    display.drawString(8, 10, "KHOA DIEN - DIEN TU");
    display.drawString(35, 25, "BAO CAO");
    display.drawString(13, 40, "DO AN TOT NGHIEP");
    display.display();
    delay(5000);
    display.clear();
    display.drawString(0, 5, "HUYNH NGOC TRANG DAI");
    display.drawString(0, 20, "19129002");
    display.drawString(0, 35, "VO THI PHUONG THAO");
    display.drawString(0, 50, "19129050");
    display.display();
  }
}

void nhip_tim() {
  pox.update();
  // Asynchronously dump heart rate and oxidation levels to the serial
  // For both, a value of 0 means "invalid"
  if (millis() - tsLastReport > REPORTING_PERIOD_MS) {
    Firebase.RTDB.getString(&fbdo, idDevice + "/spO2");
    String spO2 = fbdo.stringData();
    display.setFont(ArialMT_Plain_16);
    Firebase.RTDB.getString(&fbdo, idDevice + "/heartRate");
    String hr = fbdo.stringData();
    display.clear();
    display.drawXbm(0, 15, 15, 15, image_data_quatim);
    showBattery();
    display.drawString(20, 15, "HR: " + hr + " bpm");
    display.drawXbm(0, 35, 16, 16, image_data_quaphoi);
    display.drawString(20, 35, "SpO2: " + spO2 + " %");
    display.display();
    display.setColor(WHITE);
    // isChangeData = false;
    tsLastReport = millis();
  }
}

void setup() {
  //Register pin set
  pinMode(buzzer, OUTPUT);
  digitalWrite(buzzer, LOW);
  pinMode(button, INPUT);
  // handle wifi status
  wifiConnectHandler = WiFi.onStationModeGotIP(onWifiConnect);
  wifiDisconnectHandler = WiFi.onStationModeDisconnected(onWifiDisconnect);
  // registor set up device
  hien_thi();
  setup_wifi();
  setupFirebase();
  preprocessionMpu();
  setup_Max30100();
}

void loop() {
  if (!pox.begin()) {
    pox.begin();
    pox.setIRLedCurrent(MAX30100_LED_CURR_7_6MA);
    pox.setOnBeatDetectedCallback(onBeatDetected);
  }
  pox.update();
  temp = digitalRead(button);
  int teNgaPin = digitalRead(buzzer);

  if (fall == true) {
    setTeNgaFirebase(true);
  }

  if (temp == LOW) {
    digitalWrite(buzzer, LOW);
    fall = false;
    tadao = false;
    // reset trạng thái phát hiện té ngã trên Firebase
    if (!isSetFB) {
      isSetFB = true;
      setTeNgaFirebase(false);
      tatTaDaoTeNga();
    }
    // reset thông số phát hiện té ngã
    trigger1 = false;
    trigger2 = false;
    trigger3 = false;
    trigger1count = 0;
    trigger2count = 0;
    trigger3count = 0;
  } else {
  }

  taDaoTeNga();
  nhip_tim();
  // tenga();
}


void taDaoTeNga() {
  if (!tadao) {
    Firebase.RTDB.getBool(&fbdo, idDevice + "/taDao");
    tadao = fbdo.boolData();
    if (tadao == 1 || tadao == true) {
      teNgaTime = millis();
      fall = true;
      digitalWrite(buzzer, HIGH);
    }
  }
}

void tatTaDaoTeNga() {
  Serial.printf("Set bool... %s\n", Firebase.RTDB.setBool(&fbdo, idDevice + "/taDao", false) ? "ok" : fbdo.errorReason().c_str());
}

void setTeNgaFirebase(bool set) {
  if (Firebase.ready() && millis() - teNgaTime > 15000 && isSetFB) {
    isSetFB = false;
    Serial.printf("Set bool... %s\n", Firebase.RTDB.setBool(&fbdo, idDevice + "/isTeNga", set) ? "ok" : fbdo.errorReason().c_str());
  }
}

bool isShowSplashText() {
  sensorValue = analogRead(analogInPin);
  //  float voltage = (((sensorValue * 3.3) / 1024) * 2 + calibration); //multiply by two as voltage divider network is 100K & 100K Resistor

  bat_percentage = mapfloat(sensorValue, 2.0, 3.5, 0, 100);  //2.8V as Battery Cut off Voltage & 4.2V as Maximum Voltage

  if (bat_percentage >= 100) {
    bat_percentage = 100;
  }
  if (bat_percentage <= 0) {
    bat_percentage = 1;
    return true;
  }
  return false;
}

void tenga() {
  if (!fall) {
    // ================ Góc test code from ChatGPT =================

    // Đọc dữ liệu tốc độ góc từ cảm biến MPU6050
    int16_t GyX, GyY, GyZ;
    mpu.getRotation(&GyX, &GyY, &GyZ);

    // Áp dụng hiệu chỉnh offset và tỷ lệ chia
    float gx = (GyX - gx_offset) / gx_scale;
    float gy = (GyY - gy_offset) / gy_scale;
    float gz = (GyZ - gz_offset) / gz_scale;

    // Đọc dữ liệu gia tốc từ cảm biến MPU6050
    int16_t AcX, AcY, AcZ;
    mpu.getAcceleration(&AcX, &AcY, &AcZ);

    // Áp dụng hiệu chỉnh offset
    float ax = (AcX - ax_offset) / 16384.00;
    float ay = (AcY - ay_offset) / 16384.00;
    float az = (AcZ - az_offset) / 16384.00;

    // Tính toán Amplitude vector cho 3 trục
    float Raw_Amp = sqrt(pow(ax, 2) + pow(ay, 2) + pow(az, 2));
    int Amp = Raw_Amp * 10;  // Nhân 10 vì các giá trị nằm trong khoảng từ 0 đến 1

    if (Amp <= 0.5 && !trigger2 && !trigger3 && !trigger1) {  // Nếu Amplitude vượt qua ngưỡng thấp (0.4g)
      trigger1 = true;
      Serial.println("TRIGGER 1 ACTIVATED");
    }

    Serial.println("Amplitude: " + String(Amp));

    if (trigger1) {
      trigger1count++;
      if (Amp >= 3.0) {  // Nếu Amplitude vượt qua ngưỡng cao (3g)
        trigger2 = true;
        Serial.println("TRIGGER 2 ACTIVATED");
        trigger1 = false;
        trigger1count = 0;
      }
    }

    if (trigger2) {
      trigger2count++;
      float angleChange = pow(pow(gx, 2) + pow(gy, 2) + pow(gz, 2), 0.25);
      if (angleChange >= 80 && angleChange <= 100) {  // Nếu thay đổi hướng góc từ 80-100 độ
        trigger3 = true;
        trigger2 = false;
        trigger2count = 0;
        Serial.println("Trigger 2: " + String(angleChange));
        Serial.println("TRIGGER 3 ACTIVATED");
      }
    }

    if (trigger3) {
      trigger3count++;
      if (trigger3count >= 5) {
        float angleChange = pow(pow(gx, 2) + pow(gy, 2) + pow(gz, 2), 0.12);
        Serial.println("Trigger 3 no active: " + String(angleChange));
        if (angleChange >= 0 && angleChange <= 10) {  // Nếu thay đổi hướng góc giữa 0-10 độ
          fall = true;
          trigger3 = false;
          trigger3count = 0;
          Serial.println("Trigger 3: " + String(angleChange));
        } else {  // Người dùng đã khôi phục hướng gốc bình thường
          trigger3 = false;
          trigger3count = 0;
          Serial.println("TRIGGER 3 DEACTIVATED");
        }
      }
    }

    if (fall) {  // Trong trường hợp phát hiện té ngã
      Serial.println("FALL DETECTED");
      // teNgaTime = millis();
      // Thực hiện hành động khi phát hiện té ngã
      // digitalWrite(buzzer, HIGH);
    }

    if (trigger2count >= 6) {  // Cho phép 0.5 giây để thay đổi hướng
      trigger2 = false;
      trigger3 = false;
      trigger2count = 0;
      Serial.println("TRIGGER 2 DECACTIVATED");
    }

    if (trigger1count >= 6) {  // Cho phép 0.5 giây để Amplitude vượt qua ngưỡng cao
      trigger1 = false;
      trigger2 = false;
      trigger3 = false;
      trigger1count = 0;
      Serial.println("TRIGGER 1 DECACTIVATED");
    }

    //========================== end test ============================
  }
}

void showBattery() {
  sensorValue = analogRead(analogInPin);
  //  float voltage = (((sensorValue * 3.3) / 1024) * 2 + calibration); //multiply by two as voltage divider network is 100K & 100K Resistor

  bat_percentage = mapfloat(sensorValue, 2.0, 3.5, 0, 100);  //2.8V as Battery Cut off Voltage & 4.2V as Maximum Voltage
  if (bat_percentage >= 80) {
    return display.drawXbm(110, 0, 16, 6, image_data_battery_full);
  }
  if (bat_percentage >= 60) {
    return display.drawXbm(110, 0, 16, 6, image_data_battery_80);
  }
  if (bat_percentage >= 40) {
    return display.drawXbm(110, 0, 16, 6, image_data_battery_60);
  }
  if (bat_percentage >= 20) {
    return display.drawXbm(110, 0, 16, 6, image_data_battery_40);
  }
  if (bat_percentage >= 5) {
    return display.drawXbm(110, 0, 16, 6, image_data_battery_20);
  }
  return display.drawXbm(110, 0, 16, 6, image_data_battery_empty);
}


//Tính toán dung lượng pin hiện tại
float mapfloat(float x, float in_min, float in_max, float out_min, float out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}
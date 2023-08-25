#include <stdint.h>

static const uint8_t image_data_quatim[30] = {
  0x00, 0x00, 0x00, 0x00, 0x38, 0x0e, 0x7c, 0x1f, 0xfe, 0x3f, 0xff, 0x7f, 0xff, 0x7f, 0xff, 0x7f, 0xfe, 0x3f, 0xfc, 0x1f, 0xf8, 0x0f, 0xf0, 0x07, 0xe0, 0x03, 0xc0, 0x01, 0x00, 0x00
};
static const uint8_t image_data_quaphoi[32] = {
  0x80, 0x01, 0x80, 0x01, 0x00, 0x00, 0x80, 0x01, 0x80, 0x01, 0x00, 0x00, 0xb0, 0x0d, 0xbc, 0x3d, 0xbc, 0x3d, 0xbe, 0x7d, 0xfe, 0x7f, 0x7f, 0xfe, 0x3f, 0xfc, 0x3f, 0xfc, 0x3f, 0xfc, 0x1e, 0x78
};
static const uint8_t image_data_battery_empty[12] = {
  0xfe, 0xff, 0x03, 0x80, 0x01, 0x80, 0x01, 0x80, 0x03, 0x80, 0xfe, 0xff
};
static const uint8_t image_data_battery_20[12] = {
  0xfe, 0xff, 0x03, 0xf0, 0x01, 0xf0, 0x01, 0xf0, 0x03, 0xf0, 0xfe, 0xff,
};
static const uint8_t image_data_battery_40[12] = {
  0xfe, 0xff, 0x03, 0xfe, 0x01, 0xfe, 0x01, 0xfe, 0x03, 0xfe, 0xfe, 0xff
};
static const uint8_t image_data_battery_60[12] = {
  0xfe, 0xff, 0xc3, 0xff, 0xc1, 0xff, 0xc1, 0xff, 0xc3, 0xff, 0xfe, 0xff
};
static const uint8_t image_data_battery_80[12] = {
  0xfe, 0xff, 0xfb, 0xff, 0xf9, 0xff, 0xf9, 0xff, 0xfb, 0xff, 0xfe, 0xff,
};
static const uint8_t image_data_battery_full[12] = {
  0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xff,
};

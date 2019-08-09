// Generic
//int D0 = 16;
//int D3 = 0; 
//int D4 = 2;
// TTL
//int TX = 1;  
//int RX = 3;  
//I2C
//int D1 = 5;  // SCL
//int D2 = 4;  // SDA
//SPI
//int D5 = 14;  // SCK
//int D6 = 12;  // MISO
//int D7 = 13;  // MOSI
//int D8 = 15;  // SS

#include "ESP8266WiFi.h"                                // ���������� ���������� ESP8266WiFi
#include "Adafruit_Sensor.h"                            // Adafruit_Sensor
#include "DHT.h"                                        // ���������� ���������� DHT
#include "OneWire.h"                                    // ���������� ��� ��������� 1-wire 18B20
#include "DallasTemperature.h"                          // ���������� ��� ������ � �������� 18B20
#include "Wire.h"                                       // ���������� ��� ��������� i2c ��� BMP085
#include "Adafruit_BMP085.h"                            // ���������� ��� ������ � �������� ���������� BMP085

const char* ssid = "******";                     // �������� ����� WiFi ����
const char* password = "******";          // ������ �� ����� WiFi ����

//Analog
int ANALOG = A0;  

int analogValue = 0;
int outputValue = 0;
float dht_temp = 0;
float dallas_temp = 0;
float dht_hum = 0;
float bmp_press = 0;
float bmp_temp = 0;
float bmp_alt = 0;
 
#define DHTPIN 2                                        // ��� � �������� ��������� ������
#define DHTTYPE DHT11                                   // ������������ ������ DHT 11
DHT dht(DHTPIN, DHTTYPE);                               // �������������� ������

#define ONE_WIRE_BUS 0                                  // ���������, � ������ ������ ��������� ������ 18B20
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature DS18B20(&oneWire);
Adafruit_BMP085 bmp;
WiFiServer server(80);                                  // ��������� ���� Web-�������

void setup() {
  Serial.begin(115200);                                 // �������� �������� 115200 
  delay(10);                                            // ����� 10 ���
  Wire.begin(4, 5);                                     // ��������� �� ����������� ����� i2c �������� 
  dht.begin();                                          // ������������� DHT
  DS18B20.begin();                                      // ������������� DS18B20
  if (!bmp.begin()) {
    Serial.println("Could not find a valid BMP085 sensor, check wiring!");
    while (1) {}
  } 
   
  // �������������� D2 �� ���������� ����������� ��� ���������� �����
  pinMode(D0, OUTPUT);
  pinMode(ANALOG,  INPUT);

  Serial.println("");                                   // ������ ������ ������ 
  Serial.print("Connecting to ");                       // ������ "����������� �:"
  Serial.println(ssid);                                 // ������ "�������� ����� WiFi ����"
  
//  WiFi.begin(ssid, password);                           // ����������� � WiFi ����
  
//  while (WiFi.status() != WL_CONNECTED) (                // �������� ����������� � WiFi ����
//   delay(500);                                          // ����� 500 ���
//   Serial.print(".");                                   // ������ "."
//  }
//   Serial.println("");                                  // ������ ������ ������                                          
//   Serial.println("WiFi connected");                    // ������ "����������� � WiFi ���� ������������"
//   server.begin();                                      // ������ Web �������
//   Serial.println("Web server running.");               // ������ "���-������ �������"
//   delay(10000);                                        // ����� 10 000 ���
//   Serial.println(WiFi.localIP());                      // �������� ���������� IP-����� ESP
}

void loop() {
  analogValue = analogRead(ANALOG);                  // ���������� ������� 10 ���
  dht_temp = dht.readTemperature();                  // ������ �� ���������� ����������� DHT
  dht_hum = dht.readHumidity();                      // � ��������� DHT
  analogWrite(D0, analogValue);
  DS18B20.requestTemperatures();                   // ������ �� ���������� �����������
  dallas_temp = DS18B20.getTempCByIndex(0);

  bmp_temp = bmp.readTemperature();
  bmp_press = bmp.readPressure() / 133.3;
  bmp_alt = bmp.readAltitude();
  
  Serial.print("sensor = ");
  Serial.print(analogValue);
  Serial.print("\t 18B20 temp = ");
  Serial.print(dallas_temp);
  Serial.print("\t DHT temp = ");
  Serial.print(dht_temp);
  Serial.print("\t DHT hum = ");
  Serial.println(dht_hum);
  Serial.print("BMP085 pressure = ");
  Serial.print(bmp_press);
  Serial.print("\t BMP085 temp = ");
  Serial.println(bmp_temp);
  Serial.print("\t BMP085 altitude = ");
  Serial.println(bmp_alt);

  delay(1000);  
}
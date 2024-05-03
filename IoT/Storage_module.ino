#include <DHT.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>

#define DHTPIN 3
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

const char* ssid = "AQI";
const char* password = "aqiproject";
const char* host = "ywqiiurra7.execute-api.ap-south-1.amazonaws.com";
const int httpsPort = 443;
const int flame1 = 36; 
const int flame2 = 39; 
const int flame3 = 34; 
const int flame4 = 32; 
const int flame5 = 33; 

void setup() {
  Serial.begin(115200);
  dht.begin();
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
}

void loop() {
  String fmUID = "fm1";
  float humid = dht.readHumidity();
  float temp = dht.readTemperature();
  float flameval_1 = analogRead(flame1);
  float flameval_2 = analogRead(flame2);
  float flameval_3 = analogRead(flame3);
  float flameval_4 = analogRead(flame4);
  float flameval_5 = analogRead(flame5);
  float isFlameDetected = 0.00;
  float CO2_ppm = 400;


  if(flameval_1 >= 20.00 || flameval_2 >= 20.00 || flameval_3 >= 20.00 || flameval_4 >= 20.00 || flameval_5 >= 20.00)
  {
    isFlameDetected = 1.00;
  }

  WiFiClientSecure client2;
  client2.setInsecure();
  
  if (client2.connect(host, httpsPort)) {
    String getRequest = "GET /prod/update-storage-data?Temperature="+String(temp)+"&Humidity="+String(humid)+"&CO2="+String(CO2_ppm)+"&isFlameDetected="+String(isFlameDetected)+"&fmUID="+fmUID+" HTTP/1.1\r\n";
    getRequest += "Host: " + String(host) + "\r\n";
    getRequest += "Connection: close\r\n\r\n";
    Serial.println("Sending request:");
    Serial.println(getRequest);
    client2.print(getRequest);
    client2.stop();

  }

  delay(1000);
}

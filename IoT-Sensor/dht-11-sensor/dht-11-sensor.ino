#include <DHT.h>
#include <WiFi.h>
#include<HTTPClient.h>
#include <ArduinoJson.h>


DHT dht(26,DHT11);
const char* ssid = "<Network-Name>";
const char* password = "<Network-password>";

void setup() {
  // put your setup code here, to run once:
  dht.begin();
  delay(2000);
  
  Serial.begin(115200);

  WiFi.begin(ssid,password);
  
  while(WiFi.status() != WL_CONNECTED) {
    delay(5000);
    Serial.println("Connecting to WiFi..");
  }

  Serial.println("Connecting to the WiFi network");
}

void loop() {
  // put your main code here, to run repeatedly:
  if(WiFi.status() == WL_CONNECTED){
    HTTPClient http;

    http.begin("http://192.168.39.217:3001/sensor/data");
    http.addHeader("Content-type" , "application/json");
    
    StaticJsonDocument<128> jsonDoc;
    jsonDoc["manufacturerName"] = "John";
    jsonDoc["temperature"] = (int)dht.readTemperature();
    jsonDoc["humidity"] = (int)dht.readHumidity();
      // JSON serialize
    String jsonStr;
    serializeJson(jsonDoc, jsonStr);
    Serial.println(jsonStr);
  
    int httpResponseCode = http.POST(jsonStr);

    if(httpResponseCode>0){
      String response = http.getString();

      Serial.println(httpResponseCode);
      Serial.println(response);

    }else{
      Serial.print("Error on Sending POST: ");
    }
    
    http.end();
  }else{

    Serial.println("Error in WiFi connection");
  }
  delay(10000);
}
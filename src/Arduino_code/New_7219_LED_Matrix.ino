#include <Wire.h>
#include "RTClib.h"

#include <SoftwareSerial.h>
RTC_DS1307 rtc;
#include <MD_MAX72xx.h>
#include <MD_Parola.h>
#include <SPI.h>
SoftwareSerial BTSerial(4,5);//RX,TX
MD_Parola disp = MD_Parola(MD_MAX72XX::FC16_HW, 10, 4);


int i=0;
int hr=0;
int mn=0;
String ampm;
String mnts;
String alamppm;
bool alarmon=false;
String hrs;

void setup () {
 alarmon=false;
 Serial.begin(57600);
 BTSerial.begin(9600);
   if (! rtc.begin()) {
    
    abort();
  }


 while(i<1){
  

        printTime();
 
  }

       disp.begin();
       disp.displayClear();
       pinMode(8,OUTPUT);
         delay(2000);

}
void loop () {
 
char daysOfTheWeek[7][12] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
 DateTime now = rtc.now();
   if(now.isPM()==0)
   {
    ampm="am";
    
   }
   else if(now.isPM()==1)
   {
    ampm="pm";
   }

mnts=(String)now.minute();
if(mnts.length()<2)
{
  mnts="0"+mnts;
}
hrs.reserve(50);
if(!alarmon )
{
  hrs=(String)now.twelveHour()+":"+mnts+" "+ ampm+" "+(String)now.day()+"/"+(String)now.month()+" "+daysOfTheWeek[now.dayOfTheWeek()];
}
else 
{
  hrs=(String)now.twelveHour()+":"+mnts+" "+ ampm+" "+(String)now.day()+"/"+(String)now.month()+" "+daysOfTheWeek[now.dayOfTheWeek()]+" "+"Al "+(String)hr+":"+(String)mn+alamppm;
}

  const char *dispmsg=hrs.c_str();

  disp.setIntensity(1);
  disp.displayText(dispmsg,PA_LEFT,80,80,PA_SCROLL_LEFT,PA_SCROLL_LEFT);


  while(!disp.displayAnimate());
 disp.displayClear();

getAlarm();
clrAlarm();
soundAlarm();
 delay(1000);
}


void printTime() {
    

while(BTSerial.available()>0 && i<1)
{

 
     i++;
   int y= atoi((BTSerial.readStringUntil(':')).c_str()); 
  int m=atoi((BTSerial.readStringUntil(':')).c_str()); 
  int d=atoi((BTSerial.readStringUntil(':')).c_str()); 
   int h=atoi((BTSerial.readStringUntil(':')).c_str()); 
  int mt=atoi((BTSerial.readStringUntil(':')).c_str()); 
  int s=atoi((BTSerial.readStringUntil(':')).c_str()); 

rtc.adjust(DateTime(y,m,d,h,mt,s));

}

}



void getAlarm()
{
   
  if(BTSerial.available()>0)
{
  
  
  hr= atoi(BTSerial.readStringUntil(':').c_str()); 
  mn=atoi(BTSerial.readStringUntil(':').c_str()); 
  alamppm=BTSerial.readStringUntil(':');
  if(hr!=0 )
  {
    alarmon=true;
  }
  else
  {
    alarmon=false;
  }
  }
  

 
  }
void clrAlarm()
{
   
  if(BTSerial.available()>0)
{
  
  if(BTSerial.read()=='c')
  {
    hr=0;
    mn=0;
    alarmon=false;
    
  }

  }

 
  }

  void soundAlarm()
  {

   DateTime nw=rtc.now();
   
      if(nw.twelveHour()==hr && nw.minute()==mn && ampm==alamppm)
      {
        digitalWrite(8,HIGH);
       
      }
      else
      {
        digitalWrite(8,LOW);
  
    }
 
  }

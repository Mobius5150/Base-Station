import processing.serial.*;
import java.text.*;
import java.util.*;
import java.io.*;

PImage img;
PImage img_trans;
PImage btnstat;
PImage bar1, bar2;
PImage stat;
PImage vital;
PImage motor;
PImage speed;
PImage temp;
PImage power;
PImage statr;
PImage vitalr;
PImage motorr;
PImage speedr;
PImage tempr;
PImage connect2;
PImage connect2r;
PImage powerr, pwr_on, pwr_off;
PFont numfont;
Serial myPort;

DateFormat fnameFormat= new SimpleDateFormat("yy_MM_dd");
DateFormat  timeFormat = new SimpleDateFormat("hh:mm:ss");

byte[] inBuffer = new byte[4];
String[] data = new String[100];
String logname, logloc, information, startString, subStr;
float bar1_fade = 0, bar2_fade = 0, fuelCell_g;
int[] graph1_Data = new int[100], graph2_Data = new int[100], graph3_Data = new int[100], inData = new int[4], p_temp_amb = new int[8], p_temp_trunk = new int[8], p_temp_cab = new int[8], p_temp_fc = new int[2];
int graphWidth = 0;
int graphHeight = 300;
int FF_loc = 0, fuelCell_temp = 0, ambient_temp = 0;
int fuelCell_cur = 0;
int fuelCell_Svolt = 0, fuelCell_Bvolt = 0;
int fuelCell_H2pres = 0, fuelCell_safecode = 0;
int elec_buckVolt = 0, motor1_curr = 0, motor2_curr = 0, motor1_speed = 0, motor2_speed = 0, elec_accVolt = 0;
int temp_Trunk = 0, temp_Cabin = 0, temp_Ext = 0, bar1_val, bar2_val;
int i = 0; 
int j = 0;
int r = 0;
int z = 0;
int t = 0;
int l = 0;
int currentTime = 0, currentHour, temp_t = 0;
int pagenum;
int statX, statY;     
int btnwidth;     
int btnheight;   
int fade = 0;
boolean statOver = false;
boolean vitalOver = false;
boolean motorOver = false;
boolean speedOver = false;
boolean tempOver = false;
boolean powerOver = false;
boolean rectOver = false;
boolean connection = false, fuelCell_on = false, motor_power = false, motor_dir = false, motor_cruise = false;
boolean full = false;
Date now = new Date();


void setup() {
    
    int useThisUSBPort = 5;
    
    println(Serial.list());
    String portName = Serial.list()[useThisUSBPort];
    myPort = new Serial(this, portName, 9600);
    println(" Connecting to -> " + Serial.list()[useThisUSBPort]);
    logname = "EcoCarStatusLog" + " " + fnameFormat.format(now);
    size(1024, 768);
    numfont = loadFont("FranklinGothic-Medium-48.vlw");
    pagenum = 0;

    // Images must be in the "data" directory to load correctly
    img_trans = loadImage("bkgrnd_n.png");
    img = loadImage("bkgrnd.png");
    btnstat = loadImage("status1.png");
    bar1 = loadImage("batterybar.png");
    vital = loadImage("heart_g.png");
    motor = loadImage("motorstat_g.png");
    speed = loadImage("speed_g.png");
    temp = loadImage("temp_g.png");
    power = loadImage("powerstat_g.png");
    vitalr = loadImage("heart_r.png");
    motorr = loadImage("motorstat_r.png");
    speedr = loadImage("speed_r.png");
    powerr = loadImage("powerstat_r.png");  
    tempr = loadImage("temp_r.png");
    connect2 = loadImage("connection.png");
    connect2r = loadImage("connection_r.png");
    pwr_off = loadImage("pwr_off.png");
    pwr_on = loadImage("pwr_on.png");
    ellipseMode(CENTER);
    strokeWeight(2);
    stroke(0);
    
    char myNewline = 10;
    
    /*** Fuel Cell Log Setup ***/
    // millis, H2 pressure, safeCode, SVolt, BVolt, Temp, '/n'
    information = "EcoCar Fuel Cell Log" + 
                    str(myNewline) + 
                    str(hour()) + 
                    ":"  + 
                    str(minute()) + 
                    ":" + 
                    str(second()) + 
                    str(myNewline) + 
                    "millis, H2 Pressure, Safe Code, SVolt, BVolt, Temp";
    this.saveData(logname + " FUEL CELL", information);
    
    /*** Motors Data log ***/
    // millis, motor1_speed, motor2_speed, motor1_curr, motor2_curr, elec_buckVolt    
    information = "EcoCar Motors Log" + 
                    str(myNewline) + 
                    str(hour()) + 
                    ":"  + 
                    str(minute()) + 
                    ":" + 
                    str(second()) + 
                    str(myNewline) + 
                    "millis, motor1 Speed, motor2 Speed, motor1 Current, motor2 Current, Buck DCDC Voltage, Power, Direction, Cruise";
    this.saveData(logname + " MOTORS", information);
    
    /*** Accessory Data log ***/
    // millis, temp_Trunk, ambient_temp, temp_Cabin, elec_accVolt
    information = "EcoCar Accessory Log" + 
                    str(myNewline) + 
                    str(hour()) + 
                    ":"  + 
                    str(minute()) + 
                    ":" + 
                    str(second()) +
                    str(myNewline) + 
                    "millis, Trunk Temp, Ambient Temp, Cabin Temp, Accessory VBatt, FC Power";
    this.saveData(logname + " ACCESSORY", information);
    
}

////--------------------------------------DRAW--------------------------------------------------------------------//

void draw() {
    //  println("x -- " + mouseX);
    //  println("y --- " + mouseY);
    if (second() == 2) {
        temp_t = 29;
    }
    if (second() > temp_t) {
        temp_t = temp_t + 29;
        l = 7;
        while (l > 0) {
            p_temp_amb[l] = p_temp_amb[l-1];
            p_temp_cab[l] = p_temp_cab[l-1];
            p_temp_trunk[l] = p_temp_trunk[l-1];
            l = l - 1;
        }
        p_temp_fc[1] = p_temp_fc[0];
        p_temp_fc[0] = fuelCell_temp;
        p_temp_amb[0] = temp_Ext;
        p_temp_cab[0] = temp_Cabin;
        p_temp_trunk[0] = temp_Trunk;
        t = t + 1;
        if (t == 8) {
            t = 0;
            full = true;
        }
    }

    if (minute() == 59) {
        currentTime = 0;
    }

    //**************************************Load Main Background  
    if (pagenum == 0) {
        tint(255, 255);
        image(img, 0, 0, 1024, 768);

        //**********************************Highlight button on rollover  
        if (rectOver && pagenum == 0) {
            btnstat = loadImage("status2.png");
        } 
        else {

            btnstat = loadImage("status1.png");
        }
        tint(255, 255);  
        image(btnstat, 100, 250, 200, 40);
    }

    //************************Load Buttons for Status screens

    if (pagenum == 1 || pagenum == 2 || pagenum == 3 || pagenum == 4) {
        tint(255, 255, 255);
        image(img, 0, 0, 1024, 768);
        if (vitalOver) {
            image(vitalr, 15, 25, 100, 100);
        }
        else {
            image(vital, 15, 25, 100, 100);
        }
        if (motorOver) {
            image(motorr, 15, 150, 100, 100);
        }
        else {
            image(motor, 15, 150, 100, 100);
        }
        if (tempOver) {
            image(tempr, 15, 350, 100, 100);
        }
        else {
            image(temp, 15, 350, 100, 100);
        }
        if (powerOver) {
            image(powerr, 15, 250, 100, 100);
        }
        else {
            image(power, 15, 250, 100, 100);
        }
        if (connection) {
            image(connect2, 67, 694, 30, 30);
        }
        else {
            tint(256, 0, 153, 204);
            image(connect2, 67, 694, 30, 30);
            tint(255, 255, 255);
        }
    }

    //********************Load PAGE 1************

    if (pagenum == 1) {
        textFont(numfont, 20);
        text(fuelCell_temp, 265, 320);
        text(fuelCell_cur, 387, 174);
        text(fuelCell_Svolt, 387, 222);
        text(fuelCell_Bvolt, 387, 269);
        text(fuelCell_H2pres, 387, 75);
        text(fuelCell_safecode, 387, 124);
        text(elec_buckVolt, 386, 612);
        text(motor1_curr, 386, 520);
        text(motor2_curr, 386, 565);
        text(motor1_speed, 386, 464);
        //motor2_speed///                        
        text(elec_accVolt, 758, 668);
        text(temp_Trunk, 758, 463);
        text(temp_Cabin, 758, 567);
        text(ambient_temp, 758, 515);
        // text(temp_Ext, 850, 670);
        if (fuelCell_on) {
            image(pwr_on, 398, 29);
        }
        else {
            image(pwr_off, 398, 29);
        }
        if (motor_power) {
            image(pwr_on, 400, 415);
        }
        else {
            image(pwr_off, 400, 415);
        }
        if (motor_dir) {
            image(pwr_on, 287, 658);
        }
        else {
            image(pwr_off, 287, 658);
        }
        if (motor_cruise) {
            image(pwr_on, 446, 658);
        }
        else {
            image(pwr_off, 446, 658);
        }
        text(logname, 751, 44);
    }

    //********************Record input data to text file
    if (minute() > 58 || currentTime > 60) {
        currentTime = 0;
    }

    if (hour() != currentHour) {
        currentHour = hour();
        logname = "EcoCarStatusLog" + " " + fnameFormat.format(now);
    }

    if (currentTime <= minute() && minute() <58) {

        currentTime = minute() + 2;

        graph1_Data[i] = motor1_speed;
        graph2_Data[i] = motor1_curr;
        graph3_Data[i] = motor2_curr;
        i ++;
    }

    connection = false;

    //*******************************Draw graphs
    if (pagenum == 2) {
        textFont(numfont, 20);
        graphWidth = 0;

        // j is the fraction of the graph which is to be graphed
        if (i >1) {
            j = 485/(i-1);
            // z is the y value of the portion of the graph
            z =1;
            while (i-z >0) {
                strokeWeight(4);
                stroke(0, 0, 255);
                line(j*(z-1)+212, 348-(graph1_Data[z-1]/1.5), j*z+212, 348-(graph1_Data[z]/1.5));
                stroke(255, 0, 0);
                strokeWeight(2);
                line(j*(z-1)+212, 348-(graph1_Data[z-1]/1.5), j*z+212, 348-(graph1_Data[z]/1.5));
                z++;
            }
        }

        //speed
        text(motor1_speed, 480, 44);
        //motor1_curr
        tint(255, 255, 255);
        //      bar1_fade = motor1_curr*300/40000;
        bar1_val = (motor1_curr*300/40000);   
        tint(255-(bar1_val), 0+bar1_val, 0);
        image(bar1, 767, 345-bar1_val, 98, bar1_val);
        textFont(numfont, 20);
        text(motor1_curr, 340, 522);
        //motor2_curr
        tint(255, 255, 255);
        //      bar2_fade = motor2_curr*2.5;
        bar2_val = (motor2_curr*300/40000);   
        tint(255-(bar2_val), 0+bar2_val, 0);
        image(bar1, 886, 345-bar2_val, 98, bar2_val);
        textFont(numfont, 20);
        text(motor2_curr, 598, 520);
        //POWER INDICATORS
        tint(255, 255, 255);
        if (motor_power) {
            image(pwr_on, 274, 32);
        }
        else {
            image(pwr_off, 274, 32);
        }
        if (motor_dir) {
            image(pwr_on, 337, 616);
        }
        else {
            image(pwr_off, 337, 616);
        }
        if (motor_cruise) {
            image(pwr_on, 406, 687);
        }
        else {
            image(pwr_off, 406, 687);
        }
    }

    if (pagenum == 3) {
        textFont(numfont, 20);
        graphWidth = 0;

        if (motor_power) {
            image(pwr_on, 592, 39);
        }
        else {
            image(pwr_off, 594, 39);
        }
        fuelCell_Bvolt = 0;
        // BRANDON
        //    println("Should print");
        //    println(elec_accVolt);
        //int elec_buckVolt = 0, elec_accVolt = 0;
        text(fuelCell_cur, 315, 130);
        text(motor1_speed, 610, 130);
        text(fuelCell_Svolt, 415, 548);
        text(fuelCell_Bvolt, 415, 660);   
        text(fuelCell_safecode, 740, 550);   
        text(fuelCell_H2pres, 740, 660);
        text(elec_accVolt, 415, 601);
        text(fuelCell_temp, 887, 450);
        stroke(0, 0, 255);
        if (fuelCell_temp/220 < 50) {
            fuelCell_g = -sq(fuelCell_temp/220-50)*123/2500;
        }
        else {
            fuelCell_g = sq(fuelCell_temp/220-50)*123/2500;
        }
        line(1002, 285, 1002-123+sq(fuelCell_temp/220-50)*123/2500, 285-fuelCell_g);
    }

    if (pagenum == 4) {
        fill(0, 102, 153);  
        textFont(numfont, 30);
        text(temp_Trunk, 547, 502);
        text(temp_Cabin, 783, 502);
        text(temp_Ext, 314, 502);
        text(fuelCell_temp, 842, 662);
        fill(255, 255, 255);
        text(elec_accVolt, 468, 662);
        textFont(numfont, 20);
        text(p_temp_fc[0], 842, 662-48);
        text(p_temp_fc[1], 842, 662-48*2);
        l = 0;
        while (l <= 7) {
            text(p_temp_amb[l], 314, 502 - 50 - 43*l);
            text(p_temp_cab[l], 783, 502 - 50 - 43*l);
            text(p_temp_trunk[l], 547, 502 - 50 - 43*l);
            l = l + 1;
        }
    }

    update(mouseX, mouseY);

    if (i == 100) {
        i = 0;
    }
}
//-----------------------------------------------------------END OF DRAW-----------------

void saveData (String fileName, String newData) {

    BufferedWriter bw = null;
    try {  
        FileWriter fw = new FileWriter(dataPath(fileName) + ".txt", true);
        bw = new BufferedWriter(fw);
        bw.write(newData + System.getProperty("line.separator") + System.getProperty("line.separator"));
    } 
    catch (IOException e) {
    } 
    finally {
        if (bw != null) {
            try { 
                bw.close();
            } 
            catch (IOException e) {
            }
        }
    }
}

//Check for mouse rollover
void update(int x, int y) {
    if (overRect(100, 250, 200, 40)) {
        rectOver = true;
    } 
    else {
        rectOver = false;
    }
    //motor
    if (overRect(25, 150, 100, 100)) {
        motorOver = true;
    }
    else {
        motorOver = false;
    }
    //vital
    if (overRect(25, 25, 100, 100)) {
        vitalOver = true;
    }
    else {
        vitalOver = false;
    }
    //power
    if (overRect(35, 250, 85, 85)) {
        powerOver = true;
    }
    else {
        powerOver = false;
    }
    //temp
    if (overRect(25, 350, 100, 100)) {
        tempOver = true;
    }
    else {
        tempOver = false;
    }
}


void mousePressed() {
    if (rectOver) {
        img = loadImage("statpage.png");
        pagenum = 1;
    }
    if (vitalOver) {
        pagenum = 1;
        img = loadImage("statpage.png");
    }
    if (motorOver) {
        pagenum = 2;
        img = loadImage("motorpage.png");
    }
    if (powerOver) {
        pagenum = 3;
        img = loadImage("fuelpage.png");
    }
    if (tempOver) {
        pagenum = 4;
        img = loadImage("temperatures.png");
    }
}    

//Analyze input bytes, remove start byte and assign data
void data_cat() {
    //fuelCell_on
    if (inData[1]==0xA0) {
        if (inData[2]*256+inData[3] == 0x0000) {
            fuelCell_on = false;
        }
        if (inData[2]*256+inData[3] == 0xEEEE) {
            fuelCell_on = true;
        }
    }

    //fuelCell_temp
    if (inData[1]==0xA1) {
        fuelCell_temp = inData[2]*256+inData[3];
        fuelCell_temp = fuelCell_temp/2;
    }

    //ambient_temp
    if (inData[1]==0xA2) {
        ambient_temp = inData[2]*256+inData[3];
        ambient_temp = ambient_temp/2;
    }

    //fuelCell_cur
    if (inData[1]==0xA3) {
        fuelCell_cur = inData[2]*256+inData[3];
        fuelCell_cur = fuelCell_cur/5;
    }

    //fuelCell_Svolt
    if (inData[1]==0xA4) {
        fuelCell_Svolt = inData[2]*256+inData[3];
        fuelCell_Svolt = fuelCell_Svolt/3;
    }

    //fuelCell_Bvolt
    if (inData[1]==0xA5) {
        fuelCell_Bvolt = inData[2]*256+inData[3];
        fuelCell_Bvolt = fuelCell_Bvolt/10;
    }

    //fuelCell_H2pres
    if (inData[1]==0xA6) {
        fuelCell_H2pres = inData[2]*256+inData[3];
    }

    //fuelCell_safecode
    if (inData[1]==0xA7) {
        fuelCell_safecode = inData[2]*256+inData[3];
    }

    //elec_buckVolt
    if (inData[1]==0xB0) {
        elec_buckVolt = inData[2]*256+inData[3];
        elec_buckVolt = elec_buckVolt/10;
    }

    //Motors_on
    if (inData[1]==0xB1) {
        if (inData[2]*256+inData[3] == 0x0000) {
            motor_power = false;
        }
        if (inData[2]*256+inData[3] == 0xEEEE) {
            motor_power = true;
        }
    }

    //motor1_curr
    if (inData[1]==0xB2) {
        motor1_curr = inData[2]*256+inData[3];
    }

    //motor2_curr
    if (inData[1]==0xB3) {
        motor2_curr = inData[2]*256+inData[3];
    }

    //motor1_speed
    if (inData[1] == 0xB4) {
        motor1_speed = inData[2]*256+inData[3];
    }

    ////////////////////////////////////motor2_speed // TODO:
    motor2_speed = 0;

    //motor_dir
    if (inData[1]==0xB5) {
        if (inData[2]*256+inData[3] == 0x0000) {
            motor_dir = false;
        }
        if (inData[2]*256+inData[3] == 0xEEEE) {
            motor_dir = true;
        }
    }

    //motor_cruise
    if (inData[1]==0xB6) {
        if (inData[2]*256+inData[3] == 0x0000) {
            motor_cruise = false;
        }
        if (inData[2]*256+inData[3] == 0xEEEE) {
            motor_cruise = true;
        }
    }

    //temp_Trunk
    if (inData[1] == 0xC0) {
        temp_Trunk = inData[2];
        temp_Trunk = temp_Trunk - 30;
    }

    //temp_Cabin
    if (inData[1] == 0xC1) {
        temp_Cabin = inData[2]*256+inData[3];
        temp_Cabin = temp_Cabin - 30;
    }

    //temp_Ext
    if (inData[1] == 0xC2) {
        temp_Ext = inData[2]*256+inData[3];
        temp_Ext = temp_Ext - 30;
    }

    //elec_accVolt
    if (inData[1] == 0xC3) {

        elec_accVolt = inData[2]*256+inData[3];
        elec_accVolt = elec_accVolt/10;
    }
    
    /*** Fuel Cell Data log  ***/
    // millis, H2 pressure, safeCode, SVolt, BVolt, Temp, '/n'
    information = str(millis()) + ","  + fuelCell_H2pres + "," + fuelCell_safecode + "," + fuelCell_Svolt + "," + fuelCell_Bvolt + "," + fuelCell_temp + ',' + fuelCell_on;
    this.saveData(logname + " FUEL CELL", information);
    
    /*** Motors Data log ***/
    // millis, motor1_speed, motor2_speed, motor1_curr, motor2_curr, elec_buckVolt
    information = str(millis()) + "," + motor1_speed + "," + motor2_speed + "," + motor1_curr + "," + motor2_curr + "," + elec_buckVolt + "," + motor_power + "," + motor_dir + "," + motor_cruise;
    this.saveData(logname + " MOTORS", information);
    
    /*** Accessory Data log ***/
    // millis, temp_Trunk, ambient_temp, temp_Cabin, elec_accVolt
    information = str(millis()) + "," + temp_Trunk + "," + ambient_temp + "," + temp_Cabin + "," + elec_accVolt;
    this.saveData(logname + " ACCESSORY", information);
}

boolean overRect(int x, int y, int width, int height) {
    if (mouseX >= x && mouseX <= x+width && 
        mouseY >= y && mouseY <= y+height) {
        return true;
    } 
    else {
        return false;
    }
}

// Sync serial data to 8 byte pieces starting at "FF"
void serialEvent(Serial p) {
    if (inData[0] != 0xFF) {
        inData[0] = myPort.read();
    }
    else {
        inData[FF_loc] = myPort.read();
        FF_loc = FF_loc + 1;
        if (FF_loc == 4) {
            FF_loc = 0;
        }
        this.data_cat();
    }
    connection = true;
    println(inData);
}


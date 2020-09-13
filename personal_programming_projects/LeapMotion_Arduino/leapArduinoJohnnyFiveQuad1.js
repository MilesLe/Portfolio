/*/////////////////////////////////////////
Johnny Five API: https://github.com/rwaldron/johnny-five/wiki 
Helpful website: http://xseignard.github.io/2013/06/25/interfacing-leap-motion-with-arduino-thanks-to-nodejs/

@class This class is the Helicopter Beta 1 class

Servo API:
	- Initialize:
		var <servoName> = new five.Servo({pin: <pinNumber>, range" [<mim>, <max>], startAt: <startPos>});
	- Move:
		<servoName>.to(<pos>);
	- Stop:
		<servoName>.stop();

ESC API:
	- Initialize:
		var <escName> = new five.ESC({pin: <pinNumber>, range" [<mim>, <max>]});
	- Move:
		<escName>.to(<value>);
	- Stop:
		<escName>.stop();

Miles Notes:
	- For the Heli:     Only going to use: Y value, Pitch, and Yaw.
	- For the Y values: Make it less sensitive (division?) && make the Min 
	- For the Roll:     Make it less sensitive (division?) (only for Quadcopters)
	- For the Pitch:    Make it less sensitive (division?)
	- For the Yaw:      Don't change the sensitivity.
	- If the Servo Output DOESN'T work then try the ESC code. 
		- the joysticks might need analog inputs. Servo Output is digital.
	- LED high = 5 volts.
	- Analog write = 0 - 5 volts.
	- AnalogRead values go from 0 to 1023, AnalogWrite values from 0 to 255.

Terminal "Run" Command: 
	- node Desktop/leapArduinoJohnnyFiveQuad1.js

*//////////////////////////////////// CODE //////////////////////////////////////////////////////////

var Leap         = require('leapjs');
var five         = require('johnny-five');
var controller   = new Leap.Controller();
var handPosY     = 0;
var roll         = 0;
var pitch        = 0;
var yaw          = 0;
var handOpen     = "";
var status       = "";
var yPosMin      = 25; //start your hand here to begin flight.
var sensitivity  = 1.25; //6 is pretty High (0 - 1024). 1 is Low (400 - 600).
var nuteralSpace = 12; //the amount of nuteral space less than and greater than joyMid
var joyMin       = 0;
var joyMax       = 255;
var joyMid       = Math.round(joyMax / 2);
var board        = new five.Board();
var confidence   = 0;

/////////////////////////// Leap Connect /////////////////////////////////////
controller.on('connect', function(frame) {
  console.log("Leap Connected.");
});

controller.connect();

//////////////////////////// Arduino Board ////////////////////////////////////
board.on('ready', function(){ 
	var led         = new five.Led(13);
	var pinYvalue   = new five.Pin({pin: 0});
	var pinRoll     = new five.Pin({pin: 1});
	var pinPitch    = new five.Pin({pin: 2});
	var pinYaw      = new five.Pin({pin: 3});
	//var servoYValue = new five.Servo({pin: 9, range: [joyMin, joyMax], startAt: joyMin});
	//var servoRoll   = new five.Servo({pin: 6, range: [joyMin, joyMax], startAt: joyMid});
	//var servoPitch  = new five.Servo({pin: 5, range: [joyMin, joyMax], startAt: joyMid});
	//var servoYaw    = new five.Servo({pin: 3, range: [joyMin, joyMax], startAt: joyMid});

	///////////////////////////// Leap Hand (Data Processing) ////////////////////////
	controller.on('hand', function(hand) {
	      handPosY   = Math.round(hand.palmPosition[1] /2) - yPosMin; 
	      roll       = Math.round(hand.roll()  * 50 *  sensitivity       +joyMid);
	      pitch      = Math.round(hand.pitch() * 50 * (sensitivity +2.5) +joyMid);
	      yaw        = Math.round(hand.yaw()   * 50 * (sensitivity +2)   +joyMid);
	      confidence = Math.round(hand.confidence * 100);

	      //handOpen:
	      if (hand.grabStrength == 1){
	      	handOpen = "Closed.";
	      }
	      else{
	      	handOpen = "Open.  ";
	      }
	      //roll nuteral space: (462 - 562)
	      if (roll >= (joyMid - nuteralSpace) && roll <= (joyMid + nuteralSpace)){
	      	roll = joyMid; // makes the quad-roll nuteral.
	      }
	      //pitch nuteral space: (462 - 562)
	      if (pitch >= (joyMid - nuteralSpace) && pitch <= (joyMid + nuteralSpace)){
	      	pitch = joyMid; // makes the quad-pitch nuteral.
	      }
	      //yaw nuteral space: (462 - 562)
	      if (yaw >= (joyMid - nuteralSpace +5) && yaw <= (joyMid + nuteralSpace +5)){
	      	yaw = joyMid; // makes the quad-yaw nuteral.
	      }
	      //Data Min and Max configuring:
	      if (handPosY >= 0){
		   		handPosY = handPosY;
			} else { handPosY = 0; }
			if (handPosY <= 255){
		   		handPosY = handPosY;
			} else { handPosY = 255; }
			
			if (roll >= 0){
		   		roll = roll;
			} else { roll = 0; }
			if (roll <= 255){
		   		roll = roll;
			} else { roll = 255; }

			if (pitch >= 0){
		   		pitch = pitch;
			} else { pitch = 0; }
			if (pitch <= 255){
		   		pitch = pitch;
			} else { pitch = 255; }

			if (yaw >= 0){
		   		yaw = yaw;
			} else { yaw = 0; }
			if (yaw <= 255){
		   		pyaw = yaw;
			} else { yaw = 255; }
	      //status:
	      if (hand.grabStrength == 1 || handPosY <= 0){
	      	status = "Quad Off.";
	      	handPosY = 0;
	      	roll = joyMid;
	      	pitch = joyMid;
	      	yaw = joyMid;
	      }
	      else{
	      	status = "Quad On. ";
	      }
	});

	///////////////////////////// Leap Frame (Execute) ///////////////////////////////
	controller.on('frame', function(frame) {
		  if(frame.hands.length > 0) {
		    led.on();
			//pinYvalue.write(handPosY);

		    board.pinMode(0, five.Pin.ANALOG);
		    board.analogWrite(0, handPosY);
		    board.analogRead(0, function(voltage) {
    			console.log(voltage);
  			});
		  }
		  else{
		  	led.off();
		  	pinYvalue.write(handPosY);
			//pinRoll.write(roll);
			//pinPitch.write(pitch);
			//pinYaw.write(yaw);
		  	
		  	//servoRoll.to(roll);
		    //servoPitch.to(pitch);
		    //servoYaw.to(yaw);
		  }
		  
		  //Data Print:
	/*	  if (confidence >= 18){
		    console.log("Y = " + handPosY           + "     "
		    			+ "roll = " + roll          + "     "
		    			+ "pitch = " + pitch        + "     "
		    			+ "yaw = " + yaw            + "     "
		    			+ "hand = " + handOpen      + "     "
		    			+ "Status = " + status      + "     " 
		    			+ "confi. = " + confidence);  
	 	   }
	 	   else{ //try to make the Y-value drcease slowely.
			handPosY = handPosY;
			roll = joyMid; pitch = joyMid; yaw = joyMid;
 	   		console.log("Leap Confidence is to LOW." + "     "
 	   				+ "Y = " + handPosY          + "     "
 	   				+ "roll = " + roll           + "     "
 	   				+ "pitch = " + pitch         + "     "
 	   				+ "yaw = " + yaw );
	 	   }
	*/

	});


});
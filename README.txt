EcoCar Base Station Software
===========================

Using the Base Station Program: 
------------

1. Download/install Processing from https://www.processing.org/download/
   
2. Download the folder "eco_car2" from the EcoCar google drive.

3. Open the file "eco_car2.pde" with processing 

4. Plug the Base Station USB device into an available USB port.
	- If an installing device drivers window pops up, let it finish.
	
5. In processing, press "run" (it looks like a play button). 

6. The base station window should pop up. You can navigate around the pages to view data
   as it is broadcast from the car. 
   
Notes: 
-----

-   If you are expecting to see data, but nothing shows up, check that line 69
	in the Processing sketch "int useThisUSBPort = 0;" corresponds to the USB port
	you plugged the radio into.
	
	
-	All data is logged in csv format to .txt files. These appear in the "data" folder
	with filenames like "EcoCarStatusLog date MOTORS.txt". Open them in excel for fun
	times. 
	
	
This is an XDE project

As a component of a larger autonomous helicopter project, this XMOS based IMU will eventually give 3-Dimensional attitude information (Roll, Pitch, Yaw). The board contains:
- 1 XMOS L1-128 - This handles all of the sampling and processing of data. Inputs are listed below, and 4 1 bit ports are left for output data, to support I2C, SPI, or UART. One will be chosen (or it will be configurable), to interface with other MCUs, including another XMOS processor.
- 3 Axis Gyroscope (ADIS16060) - Each axis is it's own Gyroscope unit, as 2 axis gyroscopes have reduced performance. The Gyros are analog
- 3 Axis Accelerometer (ADXL345) - Analog outputs
- 8 Channel ADC (AD7928) - Convert the Gyroscope and Accelerometer outputs to digital SPI data, read by the XMOS. The built in sequencer allows for fast collection.
- 3 Axis Magnetometer (HMC5843) - An I2C Magnetometer. This is connected off-board via cable to move it away from sources of interference (such as the rotor motor).
- GPS (Any UART Module) - Connected via cable
The XMOS processor collects all of the data, processes it, and will stream AHRS information. The IMU filter is still to be determined, but the eventual goal is some sort of Kalman filter (independent of the physical system).
Current Status: Base IMU board designed. Magnetometer verified working with another dev kit, ADC being read. Other sensors on order.
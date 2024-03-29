/**
 * @file
 * @author Phani Gaddipati <phanigaddipati@yahoo.com>\n
 * <a href "www.centumengineering.com">Centum Engineering</a>
 * @version 1.0
 * @section License
 * This code can be used only with expressed consent from the owner
 * @section Description
 */

#ifndef ADC_FUNCS_H_
#define ADC_FUNCS_H_

#ifdef __XC__
#define EXTERNAL extern
#else
#define EXTERNAL extern "C"
#endif

float getGRoll(int rateCounts, long time);
float getGPitch(int rateCounts, long time);
float getGYaw(int rateCounts, long time);
float getDegreesSecond(int rateCounts);
float getARoll(int y, int z);
float getAPitch(int x, int y, int z);

#endif /* ADC_FUNCS_H_ */

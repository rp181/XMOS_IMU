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

EXTERNAL int getRoll(int y, int z);
EXTERNAL int getPitch(int x, int y, int z);

#endif /* ADC_FUNCS_H_ */

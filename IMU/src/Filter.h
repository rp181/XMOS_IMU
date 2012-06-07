/**
 * @file
 * @author Phani Gaddipati <phanigaddipati@yahoo.com>\n
 * <a href "www.centumengineering.com">Centum Engineering</a>
 * @version 1.0
 * @section License
 * This code can be used only with expressed consent from the owner
 * @section Description
 */

#ifndef FILTER_H_
#define FILTER_H_

#ifdef __XC__
#define EXTERNAL extern
#else
#define EXTERNAL extern "C"
#endif

EXTERNAL void initFilter();
EXTERNAL void updateFilterADCValues(int vals[8]);
EXTERNAL void updateFilterMagValues(short vals[3]);
EXTERNAL void runFilter(long time);
EXTERNAL void printVariance(int sum, int sum2, int n);
EXTERNAL void getRPY(int rpy[3]);
#endif /* FILTER_H_ */

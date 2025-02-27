/* See LICENSE file for copyright and license details. */

extern const unsigned long __heap_start[];
extern const unsigned long __heap_end[];

long
sys_brk(unsigned long brk)
{
	static unsigned long cbrk = (unsigned long)__heap_start;

	if (brk == 0)
		return cbrk;

	if (brk < (unsigned long)__heap_start || brk > (unsigned long)__heap_end)
		return -1;

	cbrk = brk;

	return cbrk;
}

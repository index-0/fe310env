/* See LICENSE file for copyright and license details. */

#include <errno.h>
#include <unistd.h>

extern void _setbyte(const unsigned char byte);

ssize_t
sys_write(int fd, const void *buf, size_t count)
{
	const unsigned char *ptr = buf;
	const unsigned char *end = ptr + count;

	if (fd != STDOUT_FILENO && fd != STDERR_FILENO) {
		errno = EBADF;
		return -1;
	}

	while (ptr < end) {
		_setbyte(*ptr++);
	}

	return ptr - (unsigned char *)buf;
}

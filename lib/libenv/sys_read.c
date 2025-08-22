/* See LICENSE file for copyright and license details. */

#include <errno.h>
#include <unistd.h>

extern unsigned char _getbyte(void);

ssize_t
sys_read(int fd, void *buf, size_t count)
{
	unsigned char *ptr = buf;
	unsigned char *end = ptr + count;
	unsigned char byte;

	if (fd != STDIN_FILENO) {
		errno = EBADF;
		return -1;
	}

	while (_getbyte() != 0x02);

	while (ptr < end) {
		byte = _getbyte();

		if (byte == 0x02)
			ptr = buf;
		else if (byte == 0x03)
			break;
		else
			*ptr++ = byte;
	}

	*ptr = 0x00;

	return ptr - (unsigned char *)buf;
}


obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5f 00 00 00       	call   f010009d <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010004e:	c7 04 24 a0 1a 10 f0 	movl   $0xf0101aa0,(%esp)
f0100055:	e8 f4 09 00 00       	call   f0100a4e <cprintf>
	if (x > 0)
f010005a:	85 db                	test   %ebx,%ebx
f010005c:	7e 0d                	jle    f010006b <test_backtrace+0x2b>
		test_backtrace(x-1);
f010005e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100061:	89 04 24             	mov    %eax,(%esp)
f0100064:	e8 d7 ff ff ff       	call   f0100040 <test_backtrace>
f0100069:	eb 1c                	jmp    f0100087 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100072:	00 
f0100073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010007a:	00 
f010007b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100082:	e8 44 07 00 00       	call   f01007cb <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 bc 1a 10 f0 	movl   $0xf0101abc,(%esp)
f0100092:	e8 b7 09 00 00       	call   f0100a4e <cprintf>
}
f0100097:	83 c4 14             	add    $0x14,%esp
f010009a:	5b                   	pop    %ebx
f010009b:	5d                   	pop    %ebp
f010009c:	c3                   	ret    

f010009d <i386_init>:

void
i386_init(void)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a3:	b8 46 29 11 f0       	mov    $0xf0112946,%eax
f01000a8:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000b8:	00 
f01000b9:	c7 04 24 00 23 11 f0 	movl   $0xf0112300,(%esp)
f01000c0:	e8 42 15 00 00       	call   f0101607 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 b5 04 00 00       	call   f010057f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 d7 1a 10 f0 	movl   $0xf0101ad7,(%esp)
f01000d9:	e8 70 09 00 00       	call   f0100a4e <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000de:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000e5:	e8 56 ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000f1:	e8 8f 07 00 00       	call   f0100885 <monitor>
f01000f6:	eb f2                	jmp    f01000ea <i386_init+0x4d>

f01000f8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f8:	55                   	push   %ebp
f01000f9:	89 e5                	mov    %esp,%ebp
f01000fb:	56                   	push   %esi
f01000fc:	53                   	push   %ebx
f01000fd:	83 ec 10             	sub    $0x10,%esp
f0100100:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100103:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f010010a:	75 3d                	jne    f0100149 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f010010c:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100112:	fa                   	cli    
f0100113:	fc                   	cld    

	va_start(ap, fmt);
f0100114:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100117:	8b 45 0c             	mov    0xc(%ebp),%eax
f010011a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010011e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100121:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100125:	c7 04 24 f2 1a 10 f0 	movl   $0xf0101af2,(%esp)
f010012c:	e8 1d 09 00 00       	call   f0100a4e <cprintf>
	vcprintf(fmt, ap);
f0100131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100135:	89 34 24             	mov    %esi,(%esp)
f0100138:	e8 de 08 00 00       	call   f0100a1b <vcprintf>
	cprintf("\n");
f010013d:	c7 04 24 2e 1b 10 f0 	movl   $0xf0101b2e,(%esp)
f0100144:	e8 05 09 00 00       	call   f0100a4e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100150:	e8 30 07 00 00       	call   f0100885 <monitor>
f0100155:	eb f2                	jmp    f0100149 <_panic+0x51>

f0100157 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100157:	55                   	push   %ebp
f0100158:	89 e5                	mov    %esp,%ebp
f010015a:	53                   	push   %ebx
f010015b:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010015e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100161:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100164:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100168:	8b 45 08             	mov    0x8(%ebp),%eax
f010016b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010016f:	c7 04 24 0a 1b 10 f0 	movl   $0xf0101b0a,(%esp)
f0100176:	e8 d3 08 00 00       	call   f0100a4e <cprintf>
	vcprintf(fmt, ap);
f010017b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010017f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100182:	89 04 24             	mov    %eax,(%esp)
f0100185:	e8 91 08 00 00       	call   f0100a1b <vcprintf>
	cprintf("\n");
f010018a:	c7 04 24 2e 1b 10 f0 	movl   $0xf0101b2e,(%esp)
f0100191:	e8 b8 08 00 00       	call   f0100a4e <cprintf>
	va_end(ap);
}
f0100196:	83 c4 14             	add    $0x14,%esp
f0100199:	5b                   	pop    %ebx
f010019a:	5d                   	pop    %ebp
f010019b:	c3                   	ret    
f010019c:	66 90                	xchg   %ax,%ax
f010019e:	66 90                	xchg   %ax,%ax

f01001a0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001a3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001a8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001a9:	a8 01                	test   $0x1,%al
f01001ab:	74 08                	je     f01001b5 <serial_proc_data+0x15>
f01001ad:	b2 f8                	mov    $0xf8,%dl
f01001af:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001b0:	0f b6 c0             	movzbl %al,%eax
f01001b3:	eb 05                	jmp    f01001ba <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001bc:	55                   	push   %ebp
f01001bd:	89 e5                	mov    %esp,%ebp
f01001bf:	53                   	push   %ebx
f01001c0:	83 ec 04             	sub    $0x4,%esp
f01001c3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001c5:	eb 2a                	jmp    f01001f1 <cons_intr+0x35>
		if (c == 0)
f01001c7:	85 d2                	test   %edx,%edx
f01001c9:	74 26                	je     f01001f1 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01001cb:	a1 24 25 11 f0       	mov    0xf0112524,%eax
f01001d0:	8d 48 01             	lea    0x1(%eax),%ecx
f01001d3:	89 0d 24 25 11 f0    	mov    %ecx,0xf0112524
f01001d9:	88 90 20 23 11 f0    	mov    %dl,-0xfeedce0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01001df:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01001e5:	75 0a                	jne    f01001f1 <cons_intr+0x35>
			cons.wpos = 0;
f01001e7:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001ee:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d3                	call   *%ebx
f01001f3:	89 c2                	mov    %eax,%edx
f01001f5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f8:	75 cd                	jne    f01001c7 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001fa:	83 c4 04             	add    $0x4,%esp
f01001fd:	5b                   	pop    %ebx
f01001fe:	5d                   	pop    %ebp
f01001ff:	c3                   	ret    

f0100200 <kbd_proc_data>:
f0100200:	ba 64 00 00 00       	mov    $0x64,%edx
f0100205:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100206:	a8 01                	test   $0x1,%al
f0100208:	0f 84 ef 00 00 00    	je     f01002fd <kbd_proc_data+0xfd>
f010020e:	b2 60                	mov    $0x60,%dl
f0100210:	ec                   	in     (%dx),%al
f0100211:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100213:	3c e0                	cmp    $0xe0,%al
f0100215:	75 0d                	jne    f0100224 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f0100217:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f010021e:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100223:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100224:	55                   	push   %ebp
f0100225:	89 e5                	mov    %esp,%ebp
f0100227:	53                   	push   %ebx
f0100228:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010022b:	84 c0                	test   %al,%al
f010022d:	79 37                	jns    f0100266 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010022f:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100235:	89 cb                	mov    %ecx,%ebx
f0100237:	83 e3 40             	and    $0x40,%ebx
f010023a:	83 e0 7f             	and    $0x7f,%eax
f010023d:	85 db                	test   %ebx,%ebx
f010023f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100242:	0f b6 d2             	movzbl %dl,%edx
f0100245:	0f b6 82 80 1c 10 f0 	movzbl -0xfefe380(%edx),%eax
f010024c:	83 c8 40             	or     $0x40,%eax
f010024f:	0f b6 c0             	movzbl %al,%eax
f0100252:	f7 d0                	not    %eax
f0100254:	21 c1                	and    %eax,%ecx
f0100256:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
		return 0;
f010025c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100261:	e9 9d 00 00 00       	jmp    f0100303 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100266:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010026c:	f6 c1 40             	test   $0x40,%cl
f010026f:	74 0e                	je     f010027f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100271:	83 c8 80             	or     $0xffffff80,%eax
f0100274:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100276:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100279:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f010027f:	0f b6 d2             	movzbl %dl,%edx
f0100282:	0f b6 82 80 1c 10 f0 	movzbl -0xfefe380(%edx),%eax
f0100289:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
	shift ^= togglecode[data];
f010028f:	0f b6 8a 80 1b 10 f0 	movzbl -0xfefe480(%edx),%ecx
f0100296:	31 c8                	xor    %ecx,%eax
f0100298:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f010029d:	89 c1                	mov    %eax,%ecx
f010029f:	83 e1 03             	and    $0x3,%ecx
f01002a2:	8b 0c 8d 60 1b 10 f0 	mov    -0xfefe4a0(,%ecx,4),%ecx
f01002a9:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002ad:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002b0:	a8 08                	test   $0x8,%al
f01002b2:	74 1b                	je     f01002cf <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f01002b4:	89 da                	mov    %ebx,%edx
f01002b6:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002b9:	83 f9 19             	cmp    $0x19,%ecx
f01002bc:	77 05                	ja     f01002c3 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f01002be:	83 eb 20             	sub    $0x20,%ebx
f01002c1:	eb 0c                	jmp    f01002cf <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f01002c3:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002c6:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002c9:	83 fa 19             	cmp    $0x19,%edx
f01002cc:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002cf:	f7 d0                	not    %eax
f01002d1:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002d3:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002d5:	f6 c2 06             	test   $0x6,%dl
f01002d8:	75 29                	jne    f0100303 <kbd_proc_data+0x103>
f01002da:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002e0:	75 21                	jne    f0100303 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f01002e2:	c7 04 24 24 1b 10 f0 	movl   $0xf0101b24,(%esp)
f01002e9:	e8 60 07 00 00       	call   f0100a4e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ee:	ba 92 00 00 00       	mov    $0x92,%edx
f01002f3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002f8:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002f9:	89 d8                	mov    %ebx,%eax
f01002fb:	eb 06                	jmp    f0100303 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100302:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100303:	83 c4 14             	add    $0x14,%esp
f0100306:	5b                   	pop    %ebx
f0100307:	5d                   	pop    %ebp
f0100308:	c3                   	ret    

f0100309 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100309:	55                   	push   %ebp
f010030a:	89 e5                	mov    %esp,%ebp
f010030c:	57                   	push   %edi
f010030d:	56                   	push   %esi
f010030e:	53                   	push   %ebx
f010030f:	83 ec 1c             	sub    $0x1c,%esp
f0100312:	89 c7                	mov    %eax,%edi
f0100314:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100319:	be fd 03 00 00       	mov    $0x3fd,%esi
f010031e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100323:	eb 0c                	jmp    f0100331 <cons_putc+0x28>
f0100325:	89 ca                	mov    %ecx,%edx
f0100327:	ec                   	in     (%dx),%al
f0100328:	89 ca                	mov    %ecx,%edx
f010032a:	ec                   	in     (%dx),%al
f010032b:	89 ca                	mov    %ecx,%edx
f010032d:	ec                   	in     (%dx),%al
f010032e:	89 ca                	mov    %ecx,%edx
f0100330:	ec                   	in     (%dx),%al
f0100331:	89 f2                	mov    %esi,%edx
f0100333:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100334:	a8 20                	test   $0x20,%al
f0100336:	75 05                	jne    f010033d <cons_putc+0x34>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100338:	83 eb 01             	sub    $0x1,%ebx
f010033b:	75 e8                	jne    f0100325 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010033d:	89 f8                	mov    %edi,%eax
f010033f:	0f b6 c0             	movzbl %al,%eax
f0100342:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100345:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010034a:	ee                   	out    %al,(%dx)
f010034b:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100350:	be 79 03 00 00       	mov    $0x379,%esi
f0100355:	b9 84 00 00 00       	mov    $0x84,%ecx
f010035a:	eb 0c                	jmp    f0100368 <cons_putc+0x5f>
f010035c:	89 ca                	mov    %ecx,%edx
f010035e:	ec                   	in     (%dx),%al
f010035f:	89 ca                	mov    %ecx,%edx
f0100361:	ec                   	in     (%dx),%al
f0100362:	89 ca                	mov    %ecx,%edx
f0100364:	ec                   	in     (%dx),%al
f0100365:	89 ca                	mov    %ecx,%edx
f0100367:	ec                   	in     (%dx),%al
f0100368:	89 f2                	mov    %esi,%edx
f010036a:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010036b:	84 c0                	test   %al,%al
f010036d:	78 05                	js     f0100374 <cons_putc+0x6b>
f010036f:	83 eb 01             	sub    $0x1,%ebx
f0100372:	75 e8                	jne    f010035c <cons_putc+0x53>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100374:	ba 78 03 00 00       	mov    $0x378,%edx
f0100379:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f010037d:	ee                   	out    %al,(%dx)
f010037e:	b2 7a                	mov    $0x7a,%dl
f0100380:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100385:	ee                   	out    %al,(%dx)
f0100386:	b8 08 00 00 00       	mov    $0x8,%eax
f010038b:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!csa) csa = 0x0700;
f010038c:	66 83 3d 44 29 11 f0 	cmpw   $0x0,0xf0112944
f0100393:	00 
f0100394:	75 09                	jne    f010039f <cons_putc+0x96>
f0100396:	66 c7 05 44 29 11 f0 	movw   $0x700,0xf0112944
f010039d:	00 07 

	if (!(c & ~0xFF))
f010039f:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003a5:	75 09                	jne    f01003b0 <cons_putc+0xa7>
		c |= csa;
f01003a7:	0f bf 05 44 29 11 f0 	movswl 0xf0112944,%eax
f01003ae:	09 c7                	or     %eax,%edi

	switch (c & 0xff) {
f01003b0:	89 f8                	mov    %edi,%eax
f01003b2:	0f b6 c0             	movzbl %al,%eax
f01003b5:	83 f8 09             	cmp    $0x9,%eax
f01003b8:	74 78                	je     f0100432 <cons_putc+0x129>
f01003ba:	83 f8 09             	cmp    $0x9,%eax
f01003bd:	7f 0a                	jg     f01003c9 <cons_putc+0xc0>
f01003bf:	83 f8 08             	cmp    $0x8,%eax
f01003c2:	74 18                	je     f01003dc <cons_putc+0xd3>
f01003c4:	e9 9d 00 00 00       	jmp    f0100466 <cons_putc+0x15d>
f01003c9:	83 f8 0a             	cmp    $0xa,%eax
f01003cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01003d0:	74 3a                	je     f010040c <cons_putc+0x103>
f01003d2:	83 f8 0d             	cmp    $0xd,%eax
f01003d5:	74 3d                	je     f0100414 <cons_putc+0x10b>
f01003d7:	e9 8a 00 00 00       	jmp    f0100466 <cons_putc+0x15d>
	case '\b':
		if (crt_pos > 0) {
f01003dc:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003e3:	66 85 c0             	test   %ax,%ax
f01003e6:	0f 84 e5 00 00 00    	je     f01004d1 <cons_putc+0x1c8>
			crt_pos--;
f01003ec:	83 e8 01             	sub    $0x1,%eax
f01003ef:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003f5:	0f b7 c0             	movzwl %ax,%eax
f01003f8:	66 81 e7 00 ff       	and    $0xff00,%di
f01003fd:	83 cf 20             	or     $0x20,%edi
f0100400:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100406:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010040a:	eb 78                	jmp    f0100484 <cons_putc+0x17b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010040c:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f0100413:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100414:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010041b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100421:	c1 e8 16             	shr    $0x16,%eax
f0100424:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100427:	c1 e0 04             	shl    $0x4,%eax
f010042a:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f0100430:	eb 52                	jmp    f0100484 <cons_putc+0x17b>
		break;
	case '\t':
		cons_putc(' ');
f0100432:	b8 20 00 00 00       	mov    $0x20,%eax
f0100437:	e8 cd fe ff ff       	call   f0100309 <cons_putc>
		cons_putc(' ');
f010043c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100441:	e8 c3 fe ff ff       	call   f0100309 <cons_putc>
		cons_putc(' ');
f0100446:	b8 20 00 00 00       	mov    $0x20,%eax
f010044b:	e8 b9 fe ff ff       	call   f0100309 <cons_putc>
		cons_putc(' ');
f0100450:	b8 20 00 00 00       	mov    $0x20,%eax
f0100455:	e8 af fe ff ff       	call   f0100309 <cons_putc>
		cons_putc(' ');
f010045a:	b8 20 00 00 00       	mov    $0x20,%eax
f010045f:	e8 a5 fe ff ff       	call   f0100309 <cons_putc>
f0100464:	eb 1e                	jmp    f0100484 <cons_putc+0x17b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100466:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010046d:	8d 50 01             	lea    0x1(%eax),%edx
f0100470:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f0100477:	0f b7 c0             	movzwl %ax,%eax
f010047a:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100480:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100484:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010048b:	cf 07 
f010048d:	76 42                	jbe    f01004d1 <cons_putc+0x1c8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010048f:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100494:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010049b:	00 
f010049c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004a2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004a6:	89 04 24             	mov    %eax,(%esp)
f01004a9:	e8 a6 11 00 00       	call   f0101654 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004ae:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004b4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004b9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004bf:	83 c0 01             	add    $0x1,%eax
f01004c2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004c7:	75 f0                	jne    f01004b9 <cons_putc+0x1b0>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004c9:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004d0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004d1:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004d7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004dc:	89 ca                	mov    %ecx,%edx
f01004de:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004df:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004e6:	8d 71 01             	lea    0x1(%ecx),%esi
f01004e9:	89 d8                	mov    %ebx,%eax
f01004eb:	66 c1 e8 08          	shr    $0x8,%ax
f01004ef:	89 f2                	mov    %esi,%edx
f01004f1:	ee                   	out    %al,(%dx)
f01004f2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004f7:	89 ca                	mov    %ecx,%edx
f01004f9:	ee                   	out    %al,(%dx)
f01004fa:	89 d8                	mov    %ebx,%eax
f01004fc:	89 f2                	mov    %esi,%edx
f01004fe:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004ff:	83 c4 1c             	add    $0x1c,%esp
f0100502:	5b                   	pop    %ebx
f0100503:	5e                   	pop    %esi
f0100504:	5f                   	pop    %edi
f0100505:	5d                   	pop    %ebp
f0100506:	c3                   	ret    

f0100507 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100507:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f010050e:	74 11                	je     f0100521 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100510:	55                   	push   %ebp
f0100511:	89 e5                	mov    %esp,%ebp
f0100513:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100516:	b8 a0 01 10 f0       	mov    $0xf01001a0,%eax
f010051b:	e8 9c fc ff ff       	call   f01001bc <cons_intr>
}
f0100520:	c9                   	leave  
f0100521:	f3 c3                	repz ret 

f0100523 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100523:	55                   	push   %ebp
f0100524:	89 e5                	mov    %esp,%ebp
f0100526:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100529:	b8 00 02 10 f0       	mov    $0xf0100200,%eax
f010052e:	e8 89 fc ff ff       	call   f01001bc <cons_intr>
}
f0100533:	c9                   	leave  
f0100534:	c3                   	ret    

f0100535 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100535:	55                   	push   %ebp
f0100536:	89 e5                	mov    %esp,%ebp
f0100538:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010053b:	e8 c7 ff ff ff       	call   f0100507 <serial_intr>
	kbd_intr();
f0100540:	e8 de ff ff ff       	call   f0100523 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100545:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f010054a:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100550:	74 26                	je     f0100578 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100552:	8d 50 01             	lea    0x1(%eax),%edx
f0100555:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010055b:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100562:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100564:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010056a:	75 11                	jne    f010057d <cons_getc+0x48>
			cons.rpos = 0;
f010056c:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100573:	00 00 00 
f0100576:	eb 05                	jmp    f010057d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100578:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010057d:	c9                   	leave  
f010057e:	c3                   	ret    

f010057f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010057f:	55                   	push   %ebp
f0100580:	89 e5                	mov    %esp,%ebp
f0100582:	57                   	push   %edi
f0100583:	56                   	push   %esi
f0100584:	53                   	push   %ebx
f0100585:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100588:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010058f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100596:	5a a5 
	if (*cp != 0xA55A) {
f0100598:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010059f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005a3:	74 11                	je     f01005b6 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01005a5:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f01005ac:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005af:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01005b4:	eb 16                	jmp    f01005cc <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01005b6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005bd:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f01005c4:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005c7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005cc:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01005d2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005d7:	89 ca                	mov    %ecx,%edx
f01005d9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005da:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005dd:	89 da                	mov    %ebx,%edx
f01005df:	ec                   	in     (%dx),%al
f01005e0:	0f b6 f0             	movzbl %al,%esi
f01005e3:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005eb:	89 ca                	mov    %ecx,%edx
f01005ed:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ee:	89 da                	mov    %ebx,%edx
f01005f0:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005f1:	89 3d 2c 25 11 f0    	mov    %edi,0xf011252c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005f7:	0f b6 d8             	movzbl %al,%ebx
f01005fa:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005fc:	66 89 35 28 25 11 f0 	mov    %si,0xf0112528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100603:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100608:	b8 00 00 00 00       	mov    $0x0,%eax
f010060d:	ee                   	out    %al,(%dx)
f010060e:	b2 fb                	mov    $0xfb,%dl
f0100610:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100615:	ee                   	out    %al,(%dx)
f0100616:	b2 f8                	mov    $0xf8,%dl
f0100618:	b8 0c 00 00 00       	mov    $0xc,%eax
f010061d:	ee                   	out    %al,(%dx)
f010061e:	b2 f9                	mov    $0xf9,%dl
f0100620:	b8 00 00 00 00       	mov    $0x0,%eax
f0100625:	ee                   	out    %al,(%dx)
f0100626:	b2 fb                	mov    $0xfb,%dl
f0100628:	b8 03 00 00 00       	mov    $0x3,%eax
f010062d:	ee                   	out    %al,(%dx)
f010062e:	b2 fc                	mov    $0xfc,%dl
f0100630:	b8 00 00 00 00       	mov    $0x0,%eax
f0100635:	ee                   	out    %al,(%dx)
f0100636:	b2 f9                	mov    $0xf9,%dl
f0100638:	b8 01 00 00 00       	mov    $0x1,%eax
f010063d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010063e:	b2 fd                	mov    $0xfd,%dl
f0100640:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100641:	3c ff                	cmp    $0xff,%al
f0100643:	0f 95 c1             	setne  %cl
f0100646:	88 0d 34 25 11 f0    	mov    %cl,0xf0112534
f010064c:	b2 fa                	mov    $0xfa,%dl
f010064e:	ec                   	in     (%dx),%al
f010064f:	b2 f8                	mov    $0xf8,%dl
f0100651:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100652:	84 c9                	test   %cl,%cl
f0100654:	75 0c                	jne    f0100662 <cons_init+0xe3>
		cprintf("Serial port does not exist!\n");
f0100656:	c7 04 24 30 1b 10 f0 	movl   $0xf0101b30,(%esp)
f010065d:	e8 ec 03 00 00       	call   f0100a4e <cprintf>
}
f0100662:	83 c4 1c             	add    $0x1c,%esp
f0100665:	5b                   	pop    %ebx
f0100666:	5e                   	pop    %esi
f0100667:	5f                   	pop    %edi
f0100668:	5d                   	pop    %ebp
f0100669:	c3                   	ret    

f010066a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010066a:	55                   	push   %ebp
f010066b:	89 e5                	mov    %esp,%ebp
f010066d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100670:	8b 45 08             	mov    0x8(%ebp),%eax
f0100673:	e8 91 fc ff ff       	call   f0100309 <cons_putc>
}
f0100678:	c9                   	leave  
f0100679:	c3                   	ret    

f010067a <getchar>:

int
getchar(void)
{
f010067a:	55                   	push   %ebp
f010067b:	89 e5                	mov    %esp,%ebp
f010067d:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100680:	e8 b0 fe ff ff       	call   f0100535 <cons_getc>
f0100685:	85 c0                	test   %eax,%eax
f0100687:	74 f7                	je     f0100680 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100689:	c9                   	leave  
f010068a:	c3                   	ret    

f010068b <iscons>:

int
iscons(int fdnum)
{
f010068b:	55                   	push   %ebp
f010068c:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010068e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100693:	5d                   	pop    %ebp
f0100694:	c3                   	ret    
f0100695:	66 90                	xchg   %ax,%ax
f0100697:	66 90                	xchg   %ax,%ax
f0100699:	66 90                	xchg   %ax,%ax
f010069b:	66 90                	xchg   %ax,%ax
f010069d:	66 90                	xchg   %ax,%ax
f010069f:	90                   	nop

f01006a0 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006a0:	55                   	push   %ebp
f01006a1:	89 e5                	mov    %esp,%ebp
f01006a3:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006a6:	c7 44 24 08 80 1d 10 	movl   $0xf0101d80,0x8(%esp)
f01006ad:	f0 
f01006ae:	c7 44 24 04 9e 1d 10 	movl   $0xf0101d9e,0x4(%esp)
f01006b5:	f0 
f01006b6:	c7 04 24 a3 1d 10 f0 	movl   $0xf0101da3,(%esp)
f01006bd:	e8 8c 03 00 00       	call   f0100a4e <cprintf>
f01006c2:	c7 44 24 08 88 1e 10 	movl   $0xf0101e88,0x8(%esp)
f01006c9:	f0 
f01006ca:	c7 44 24 04 ac 1d 10 	movl   $0xf0101dac,0x4(%esp)
f01006d1:	f0 
f01006d2:	c7 04 24 a3 1d 10 f0 	movl   $0xf0101da3,(%esp)
f01006d9:	e8 70 03 00 00       	call   f0100a4e <cprintf>
f01006de:	c7 44 24 08 b0 1e 10 	movl   $0xf0101eb0,0x8(%esp)
f01006e5:	f0 
f01006e6:	c7 44 24 04 b5 1d 10 	movl   $0xf0101db5,0x4(%esp)
f01006ed:	f0 
f01006ee:	c7 04 24 a3 1d 10 f0 	movl   $0xf0101da3,(%esp)
f01006f5:	e8 54 03 00 00       	call   f0100a4e <cprintf>
	return 0;
}
f01006fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ff:	c9                   	leave  
f0100700:	c3                   	ret    

f0100701 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100701:	55                   	push   %ebp
f0100702:	89 e5                	mov    %esp,%ebp
f0100704:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100707:	c7 04 24 bf 1d 10 f0 	movl   $0xf0101dbf,(%esp)
f010070e:	e8 3b 03 00 00       	call   f0100a4e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100713:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010071a:	00 
f010071b:	c7 04 24 d4 1e 10 f0 	movl   $0xf0101ed4,(%esp)
f0100722:	e8 27 03 00 00       	call   f0100a4e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100727:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010072e:	00 
f010072f:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100736:	f0 
f0100737:	c7 04 24 fc 1e 10 f0 	movl   $0xf0101efc,(%esp)
f010073e:	e8 0b 03 00 00       	call   f0100a4e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100743:	c7 44 24 08 97 1a 10 	movl   $0x101a97,0x8(%esp)
f010074a:	00 
f010074b:	c7 44 24 04 97 1a 10 	movl   $0xf0101a97,0x4(%esp)
f0100752:	f0 
f0100753:	c7 04 24 20 1f 10 f0 	movl   $0xf0101f20,(%esp)
f010075a:	e8 ef 02 00 00       	call   f0100a4e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010075f:	c7 44 24 08 00 23 11 	movl   $0x112300,0x8(%esp)
f0100766:	00 
f0100767:	c7 44 24 04 00 23 11 	movl   $0xf0112300,0x4(%esp)
f010076e:	f0 
f010076f:	c7 04 24 44 1f 10 f0 	movl   $0xf0101f44,(%esp)
f0100776:	e8 d3 02 00 00       	call   f0100a4e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010077b:	c7 44 24 08 46 29 11 	movl   $0x112946,0x8(%esp)
f0100782:	00 
f0100783:	c7 44 24 04 46 29 11 	movl   $0xf0112946,0x4(%esp)
f010078a:	f0 
f010078b:	c7 04 24 68 1f 10 f0 	movl   $0xf0101f68,(%esp)
f0100792:	e8 b7 02 00 00       	call   f0100a4e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100797:	b8 45 2d 11 f0       	mov    $0xf0112d45,%eax
f010079c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01007a1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007a6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007ac:	85 c0                	test   %eax,%eax
f01007ae:	0f 48 c2             	cmovs  %edx,%eax
f01007b1:	c1 f8 0a             	sar    $0xa,%eax
f01007b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007b8:	c7 04 24 8c 1f 10 f0 	movl   $0xf0101f8c,(%esp)
f01007bf:	e8 8a 02 00 00       	call   f0100a4e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01007c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01007c9:	c9                   	leave  
f01007ca:	c3                   	ret    

f01007cb <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01007cb:	55                   	push   %ebp
f01007cc:	89 e5                	mov    %esp,%ebp
f01007ce:	57                   	push   %edi
f01007cf:	56                   	push   %esi
f01007d0:	53                   	push   %ebx
f01007d1:	83 ec 4c             	sub    $0x4c,%esp
	// Your code here.
	uint32_t * ebp = ( uint32_t* ) read_ebp();
f01007d4:	89 ee                	mov    %ebp,%esi
	cprintf("Stack backtrace:\n");
f01007d6:	c7 04 24 d8 1d 10 f0 	movl   $0xf0101dd8,(%esp)
f01007dd:	e8 6c 02 00 00       	call   f0100a4e <cprintf>
			cprintf(" %08x",*(ebp+i));
		}
		cprintf("\n");

		struct Eipdebuginfo info;
		int val = debuginfo_eip(*(ebp+1) , &info);
f01007e2:	8d 7d d0             	lea    -0x30(%ebp),%edi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	uint32_t * ebp = ( uint32_t* ) read_ebp();
	cprintf("Stack backtrace:\n");
	while( ebp != NULL){
f01007e5:	e9 86 00 00 00       	jmp    f0100870 <mon_backtrace+0xa5>
		cprintf("ebp %x eip %x args",(ebp),*(ebp+1));
f01007ea:	8b 46 04             	mov    0x4(%esi),%eax
f01007ed:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007f1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01007f5:	c7 04 24 ea 1d 10 f0 	movl   $0xf0101dea,(%esp)
f01007fc:	e8 4d 02 00 00       	call   f0100a4e <cprintf>

		int i = 2;
f0100801:	bb 02 00 00 00       	mov    $0x2,%ebx
		for( ; i < 7; i++){
			cprintf(" %08x",*(ebp+i));
f0100806:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
f0100809:	89 44 24 04          	mov    %eax,0x4(%esp)
f010080d:	c7 04 24 fd 1d 10 f0 	movl   $0xf0101dfd,(%esp)
f0100814:	e8 35 02 00 00       	call   f0100a4e <cprintf>
	cprintf("Stack backtrace:\n");
	while( ebp != NULL){
		cprintf("ebp %x eip %x args",(ebp),*(ebp+1));

		int i = 2;
		for( ; i < 7; i++){
f0100819:	83 c3 01             	add    $0x1,%ebx
f010081c:	83 fb 07             	cmp    $0x7,%ebx
f010081f:	75 e5                	jne    f0100806 <mon_backtrace+0x3b>
			cprintf(" %08x",*(ebp+i));
		}
		cprintf("\n");
f0100821:	c7 04 24 2e 1b 10 f0 	movl   $0xf0101b2e,(%esp)
f0100828:	e8 21 02 00 00       	call   f0100a4e <cprintf>

		struct Eipdebuginfo info;
		int val = debuginfo_eip(*(ebp+1) , &info);
f010082d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100831:	8b 46 04             	mov    0x4(%esi),%eax
f0100834:	89 04 24             	mov    %eax,(%esp)
f0100837:	e8 09 03 00 00       	call   f0100b45 <debuginfo_eip>
		// ex : kern/monitor.c:143: monitor+106
		cprintf("\t%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen, info.eip_fn_name,
f010083c:	8b 46 04             	mov    0x4(%esi),%eax
f010083f:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100842:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100846:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100849:	89 44 24 10          	mov    %eax,0x10(%esp)
f010084d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100850:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100854:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100857:	89 44 24 08          	mov    %eax,0x8(%esp)
f010085b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010085e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100862:	c7 04 24 03 1e 10 f0 	movl   $0xf0101e03,(%esp)
f0100869:	e8 e0 01 00 00       	call   f0100a4e <cprintf>
      *(ebp+1) - info.eip_fn_addr  );

		ebp = ( uint32_t * ) * ebp;
f010086e:	8b 36                	mov    (%esi),%esi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	uint32_t * ebp = ( uint32_t* ) read_ebp();
	cprintf("Stack backtrace:\n");
	while( ebp != NULL){
f0100870:	85 f6                	test   %esi,%esi
f0100872:	0f 85 72 ff ff ff    	jne    f01007ea <mon_backtrace+0x1f>
      *(ebp+1) - info.eip_fn_addr  );

		ebp = ( uint32_t * ) * ebp;
	}
	return 0;
}	
f0100878:	b8 00 00 00 00       	mov    $0x0,%eax
f010087d:	83 c4 4c             	add    $0x4c,%esp
f0100880:	5b                   	pop    %ebx
f0100881:	5e                   	pop    %esi
f0100882:	5f                   	pop    %edi
f0100883:	5d                   	pop    %ebp
f0100884:	c3                   	ret    

f0100885 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100885:	55                   	push   %ebp
f0100886:	89 e5                	mov    %esp,%ebp
f0100888:	57                   	push   %edi
f0100889:	56                   	push   %esi
f010088a:	53                   	push   %ebx
f010088b:	83 ec 6c             	sub    $0x6c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010088e:	c7 04 24 b8 1f 10 f0 	movl   $0xf0101fb8,(%esp)
f0100895:	e8 b4 01 00 00       	call   f0100a4e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010089a:	c7 04 24 dc 1f 10 f0 	movl   $0xf0101fdc,(%esp)
f01008a1:	e8 a8 01 00 00       	call   f0100a4e <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n", 
f01008a6:	c7 44 24 18 14 1e 10 	movl   $0xf0101e14,0x18(%esp)
f01008ad:	f0 
f01008ae:	c7 44 24 14 00 04 00 	movl   $0x400,0x14(%esp)
f01008b5:	00 
f01008b6:	c7 44 24 10 18 1e 10 	movl   $0xf0101e18,0x10(%esp)
f01008bd:	f0 
f01008be:	c7 44 24 0c 00 02 00 	movl   $0x200,0xc(%esp)
f01008c5:	00 
f01008c6:	c7 44 24 08 1e 1e 10 	movl   $0xf0101e1e,0x8(%esp)
f01008cd:	f0 
f01008ce:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
f01008d5:	00 
f01008d6:	c7 04 24 23 1e 10 f0 	movl   $0xf0101e23,(%esp)
f01008dd:	e8 6c 01 00 00       	call   f0100a4e <cprintf>
    0x0100, "blue", 0x0200, "green", 0x0400, "red");

	cprintf("x=%d y=%d\n", 3);
f01008e2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01008e9:	00 
f01008ea:	c7 04 24 33 1e 10 f0 	movl   $0xf0101e33,(%esp)
f01008f1:	e8 58 01 00 00       	call   f0100a4e <cprintf>

	while (1) {
		buf = readline("AbtalELDigital> ");
f01008f6:	c7 04 24 3e 1e 10 f0 	movl   $0xf0101e3e,(%esp)
f01008fd:	e8 9e 0a 00 00       	call   f01013a0 <readline>
f0100902:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100904:	85 c0                	test   %eax,%eax
f0100906:	74 ee                	je     f01008f6 <monitor+0x71>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100908:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010090f:	be 00 00 00 00       	mov    $0x0,%esi
f0100914:	eb 0a                	jmp    f0100920 <monitor+0x9b>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100916:	c6 03 00             	movb   $0x0,(%ebx)
f0100919:	89 f7                	mov    %esi,%edi
f010091b:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010091e:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100920:	0f b6 03             	movzbl (%ebx),%eax
f0100923:	84 c0                	test   %al,%al
f0100925:	74 63                	je     f010098a <monitor+0x105>
f0100927:	0f be c0             	movsbl %al,%eax
f010092a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010092e:	c7 04 24 4f 1e 10 f0 	movl   $0xf0101e4f,(%esp)
f0100935:	e8 90 0c 00 00       	call   f01015ca <strchr>
f010093a:	85 c0                	test   %eax,%eax
f010093c:	75 d8                	jne    f0100916 <monitor+0x91>
			*buf++ = 0;
		if (*buf == 0)
f010093e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100941:	74 47                	je     f010098a <monitor+0x105>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100943:	83 fe 0f             	cmp    $0xf,%esi
f0100946:	75 16                	jne    f010095e <monitor+0xd9>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100948:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010094f:	00 
f0100950:	c7 04 24 54 1e 10 f0 	movl   $0xf0101e54,(%esp)
f0100957:	e8 f2 00 00 00       	call   f0100a4e <cprintf>
f010095c:	eb 98                	jmp    f01008f6 <monitor+0x71>
			return 0;
		}
		argv[argc++] = buf;
f010095e:	8d 7e 01             	lea    0x1(%esi),%edi
f0100961:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100965:	eb 03                	jmp    f010096a <monitor+0xe5>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100967:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010096a:	0f b6 03             	movzbl (%ebx),%eax
f010096d:	84 c0                	test   %al,%al
f010096f:	74 ad                	je     f010091e <monitor+0x99>
f0100971:	0f be c0             	movsbl %al,%eax
f0100974:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100978:	c7 04 24 4f 1e 10 f0 	movl   $0xf0101e4f,(%esp)
f010097f:	e8 46 0c 00 00       	call   f01015ca <strchr>
f0100984:	85 c0                	test   %eax,%eax
f0100986:	74 df                	je     f0100967 <monitor+0xe2>
f0100988:	eb 94                	jmp    f010091e <monitor+0x99>
			buf++;
	}
	argv[argc] = 0;
f010098a:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100991:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100992:	85 f6                	test   %esi,%esi
f0100994:	0f 84 5c ff ff ff    	je     f01008f6 <monitor+0x71>
f010099a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010099f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009a2:	8b 04 85 20 20 10 f0 	mov    -0xfefdfe0(,%eax,4),%eax
f01009a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009ad:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009b0:	89 04 24             	mov    %eax,(%esp)
f01009b3:	e8 b4 0b 00 00       	call   f010156c <strcmp>
f01009b8:	85 c0                	test   %eax,%eax
f01009ba:	75 24                	jne    f01009e0 <monitor+0x15b>
			return commands[i].func(argc, argv, tf);
f01009bc:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009bf:	8b 55 08             	mov    0x8(%ebp),%edx
f01009c2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01009c6:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01009c9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01009cd:	89 34 24             	mov    %esi,(%esp)
f01009d0:	ff 14 85 28 20 10 f0 	call   *-0xfefdfd8(,%eax,4)
	cprintf("x=%d y=%d\n", 3);

	while (1) {
		buf = readline("AbtalELDigital> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009d7:	85 c0                	test   %eax,%eax
f01009d9:	78 25                	js     f0100a00 <monitor+0x17b>
f01009db:	e9 16 ff ff ff       	jmp    f01008f6 <monitor+0x71>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01009e0:	83 c3 01             	add    $0x1,%ebx
f01009e3:	83 fb 03             	cmp    $0x3,%ebx
f01009e6:	75 b7                	jne    f010099f <monitor+0x11a>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009e8:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009ef:	c7 04 24 71 1e 10 f0 	movl   $0xf0101e71,(%esp)
f01009f6:	e8 53 00 00 00       	call   f0100a4e <cprintf>
f01009fb:	e9 f6 fe ff ff       	jmp    f01008f6 <monitor+0x71>
		buf = readline("AbtalELDigital> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a00:	83 c4 6c             	add    $0x6c,%esp
f0100a03:	5b                   	pop    %ebx
f0100a04:	5e                   	pop    %esi
f0100a05:	5f                   	pop    %edi
f0100a06:	5d                   	pop    %ebp
f0100a07:	c3                   	ret    

f0100a08 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100a08:	55                   	push   %ebp
f0100a09:	89 e5                	mov    %esp,%ebp
f0100a0b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100a0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a11:	89 04 24             	mov    %eax,(%esp)
f0100a14:	e8 51 fc ff ff       	call   f010066a <cputchar>
	*cnt++;
}
f0100a19:	c9                   	leave  
f0100a1a:	c3                   	ret    

f0100a1b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100a1b:	55                   	push   %ebp
f0100a1c:	89 e5                	mov    %esp,%ebp
f0100a1e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100a21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap); // send numofper
f0100a28:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a2f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a32:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a36:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a3d:	c7 04 24 08 0a 10 f0 	movl   $0xf0100a08,(%esp)
f0100a44:	e8 b5 04 00 00       	call   f0100efe <vprintfmt>
	return cnt;
}
f0100a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a4c:	c9                   	leave  
f0100a4d:	c3                   	ret    

f0100a4e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a4e:	55                   	push   %ebp
f0100a4f:	89 e5                	mov    %esp,%ebp
f0100a51:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	// loop over fmt, count all % -- 
	va_start(ap, fmt);
f0100a54:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap); // send numofper
f0100a57:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a5e:	89 04 24             	mov    %eax,(%esp)
f0100a61:	e8 b5 ff ff ff       	call   f0100a1b <vcprintf>
	va_end(ap);

	return cnt;
}
f0100a66:	c9                   	leave  
f0100a67:	c3                   	ret    

f0100a68 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100a68:	55                   	push   %ebp
f0100a69:	89 e5                	mov    %esp,%ebp
f0100a6b:	57                   	push   %edi
f0100a6c:	56                   	push   %esi
f0100a6d:	53                   	push   %ebx
f0100a6e:	83 ec 10             	sub    $0x10,%esp
f0100a71:	89 c6                	mov    %eax,%esi
f0100a73:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100a76:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100a79:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a7c:	8b 1a                	mov    (%edx),%ebx
f0100a7e:	8b 01                	mov    (%ecx),%eax
f0100a80:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a83:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0100a8a:	eb 77                	jmp    f0100b03 <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f0100a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a8f:	01 d8                	add    %ebx,%eax
f0100a91:	b9 02 00 00 00       	mov    $0x2,%ecx
f0100a96:	99                   	cltd   
f0100a97:	f7 f9                	idiv   %ecx
f0100a99:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a9b:	eb 01                	jmp    f0100a9e <stab_binsearch+0x36>
			m--;
f0100a9d:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a9e:	39 d9                	cmp    %ebx,%ecx
f0100aa0:	7c 1d                	jl     f0100abf <stab_binsearch+0x57>
f0100aa2:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0100aa5:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100aaa:	39 fa                	cmp    %edi,%edx
f0100aac:	75 ef                	jne    f0100a9d <stab_binsearch+0x35>
f0100aae:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100ab1:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0100ab4:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0100ab8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100abb:	73 18                	jae    f0100ad5 <stab_binsearch+0x6d>
f0100abd:	eb 05                	jmp    f0100ac4 <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100abf:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f0100ac2:	eb 3f                	jmp    f0100b03 <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100ac4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100ac7:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0100ac9:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100acc:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100ad3:	eb 2e                	jmp    f0100b03 <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100ad5:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100ad8:	73 15                	jae    f0100aef <stab_binsearch+0x87>
			*region_right = m - 1;
f0100ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100add:	48                   	dec    %eax
f0100ade:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100ae1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100ae4:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100ae6:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100aed:	eb 14                	jmp    f0100b03 <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100aef:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100af2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0100af5:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0100af7:	ff 45 0c             	incl   0xc(%ebp)
f0100afa:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100afc:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100b03:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100b06:	7e 84                	jle    f0100a8c <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100b08:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100b0c:	75 0d                	jne    f0100b1b <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0100b0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100b11:	8b 00                	mov    (%eax),%eax
f0100b13:	48                   	dec    %eax
f0100b14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b17:	89 07                	mov    %eax,(%edi)
f0100b19:	eb 22                	jmp    f0100b3d <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b1e:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100b20:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100b23:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b25:	eb 01                	jmp    f0100b28 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100b27:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b28:	39 c1                	cmp    %eax,%ecx
f0100b2a:	7d 0c                	jge    f0100b38 <stab_binsearch+0xd0>
f0100b2c:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0100b2f:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100b34:	39 fa                	cmp    %edi,%edx
f0100b36:	75 ef                	jne    f0100b27 <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100b38:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0100b3b:	89 07                	mov    %eax,(%edi)
	}
}
f0100b3d:	83 c4 10             	add    $0x10,%esp
f0100b40:	5b                   	pop    %ebx
f0100b41:	5e                   	pop    %esi
f0100b42:	5f                   	pop    %edi
f0100b43:	5d                   	pop    %ebp
f0100b44:	c3                   	ret    

f0100b45 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b45:	55                   	push   %ebp
f0100b46:	89 e5                	mov    %esp,%ebp
f0100b48:	57                   	push   %edi
f0100b49:	56                   	push   %esi
f0100b4a:	53                   	push   %ebx
f0100b4b:	83 ec 3c             	sub    $0x3c,%esp
f0100b4e:	8b 75 08             	mov    0x8(%ebp),%esi
f0100b51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b54:	c7 03 44 20 10 f0    	movl   $0xf0102044,(%ebx)
	info->eip_line = 0;
f0100b5a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100b61:	c7 43 08 44 20 10 f0 	movl   $0xf0102044,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100b68:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100b6f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100b72:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b79:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100b7f:	76 12                	jbe    f0100b93 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b81:	b8 10 76 10 f0       	mov    $0xf0107610,%eax
f0100b86:	3d dd 5c 10 f0       	cmp    $0xf0105cdd,%eax
f0100b8b:	0f 86 ca 01 00 00    	jbe    f0100d5b <debuginfo_eip+0x216>
f0100b91:	eb 1c                	jmp    f0100baf <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b93:	c7 44 24 08 4e 20 10 	movl   $0xf010204e,0x8(%esp)
f0100b9a:	f0 
f0100b9b:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100ba2:	00 
f0100ba3:	c7 04 24 5b 20 10 f0 	movl   $0xf010205b,(%esp)
f0100baa:	e8 49 f5 ff ff       	call   f01000f8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100baf:	80 3d 0f 76 10 f0 00 	cmpb   $0x0,0xf010760f
f0100bb6:	0f 85 a6 01 00 00    	jne    f0100d62 <debuginfo_eip+0x21d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100bbc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100bc3:	b8 dc 5c 10 f0       	mov    $0xf0105cdc,%eax
f0100bc8:	2d 98 22 10 f0       	sub    $0xf0102298,%eax
f0100bcd:	c1 f8 02             	sar    $0x2,%eax
f0100bd0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100bd6:	83 e8 01             	sub    $0x1,%eax
f0100bd9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100bdc:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100be0:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100be7:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100bea:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100bed:	b8 98 22 10 f0       	mov    $0xf0102298,%eax
f0100bf2:	e8 71 fe ff ff       	call   f0100a68 <stab_binsearch>
	if (lfile == 0)
f0100bf7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bfa:	85 c0                	test   %eax,%eax
f0100bfc:	0f 84 67 01 00 00    	je     f0100d69 <debuginfo_eip+0x224>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c02:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100c05:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c08:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c0b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c0f:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100c16:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c19:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c1c:	b8 98 22 10 f0       	mov    $0xf0102298,%eax
f0100c21:	e8 42 fe ff ff       	call   f0100a68 <stab_binsearch>

	if (lfun <= rfun) {
f0100c26:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c29:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100c2c:	39 d0                	cmp    %edx,%eax
f0100c2e:	7f 3d                	jg     f0100c6d <debuginfo_eip+0x128>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c30:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0100c33:	8d b9 98 22 10 f0    	lea    -0xfefdd68(%ecx),%edi
f0100c39:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100c3c:	8b 89 98 22 10 f0    	mov    -0xfefdd68(%ecx),%ecx
f0100c42:	bf 10 76 10 f0       	mov    $0xf0107610,%edi
f0100c47:	81 ef dd 5c 10 f0    	sub    $0xf0105cdd,%edi
f0100c4d:	39 f9                	cmp    %edi,%ecx
f0100c4f:	73 09                	jae    f0100c5a <debuginfo_eip+0x115>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c51:	81 c1 dd 5c 10 f0    	add    $0xf0105cdd,%ecx
f0100c57:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c5a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100c5d:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100c60:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100c63:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100c65:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100c68:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100c6b:	eb 0f                	jmp    f0100c7c <debuginfo_eip+0x137>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100c6d:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c73:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100c76:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c79:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c7c:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100c83:	00 
f0100c84:	8b 43 08             	mov    0x8(%ebx),%eax
f0100c87:	89 04 24             	mov    %eax,(%esp)
f0100c8a:	e8 5c 09 00 00       	call   f01015eb <strfind>
f0100c8f:	2b 43 08             	sub    0x8(%ebx),%eax
f0100c92:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100c95:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c99:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0100ca0:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100ca3:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100ca6:	b8 98 22 10 f0       	mov    $0xf0102298,%eax
f0100cab:	e8 b8 fd ff ff       	call   f0100a68 <stab_binsearch>
	if ( lline <= rline){
f0100cb0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100cb3:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100cb6:	0f 8f b4 00 00 00    	jg     f0100d70 <debuginfo_eip+0x22b>
		info->eip_line = stabs[lline].n_desc;
f0100cbc:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100cbf:	0f b7 80 9e 22 10 f0 	movzwl -0xfefdd62(%eax),%eax
f0100cc6:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100cc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ccc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100ccf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100cd2:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100cd5:	81 c2 98 22 10 f0    	add    $0xf0102298,%edx
f0100cdb:	eb 06                	jmp    f0100ce3 <debuginfo_eip+0x19e>
f0100cdd:	83 e8 01             	sub    $0x1,%eax
f0100ce0:	83 ea 0c             	sub    $0xc,%edx
f0100ce3:	89 c6                	mov    %eax,%esi
f0100ce5:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100ce8:	7f 33                	jg     f0100d1d <debuginfo_eip+0x1d8>
	       && stabs[lline].n_type != N_SOL
f0100cea:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100cee:	80 f9 84             	cmp    $0x84,%cl
f0100cf1:	74 0b                	je     f0100cfe <debuginfo_eip+0x1b9>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100cf3:	80 f9 64             	cmp    $0x64,%cl
f0100cf6:	75 e5                	jne    f0100cdd <debuginfo_eip+0x198>
f0100cf8:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0100cfc:	74 df                	je     f0100cdd <debuginfo_eip+0x198>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100cfe:	6b f6 0c             	imul   $0xc,%esi,%esi
f0100d01:	8b 86 98 22 10 f0    	mov    -0xfefdd68(%esi),%eax
f0100d07:	ba 10 76 10 f0       	mov    $0xf0107610,%edx
f0100d0c:	81 ea dd 5c 10 f0    	sub    $0xf0105cdd,%edx
f0100d12:	39 d0                	cmp    %edx,%eax
f0100d14:	73 07                	jae    f0100d1d <debuginfo_eip+0x1d8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100d16:	05 dd 5c 10 f0       	add    $0xf0105cdd,%eax
f0100d1b:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d1d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d20:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d23:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d28:	39 ca                	cmp    %ecx,%edx
f0100d2a:	7d 50                	jge    f0100d7c <debuginfo_eip+0x237>
		for (lline = lfun + 1;
f0100d2c:	8d 42 01             	lea    0x1(%edx),%eax
f0100d2f:	89 c2                	mov    %eax,%edx
f0100d31:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100d34:	05 98 22 10 f0       	add    $0xf0102298,%eax
f0100d39:	89 ce                	mov    %ecx,%esi
f0100d3b:	eb 04                	jmp    f0100d41 <debuginfo_eip+0x1fc>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100d3d:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100d41:	39 d6                	cmp    %edx,%esi
f0100d43:	7e 32                	jle    f0100d77 <debuginfo_eip+0x232>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d45:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100d49:	83 c2 01             	add    $0x1,%edx
f0100d4c:	83 c0 0c             	add    $0xc,%eax
f0100d4f:	80 f9 a0             	cmp    $0xa0,%cl
f0100d52:	74 e9                	je     f0100d3d <debuginfo_eip+0x1f8>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d54:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d59:	eb 21                	jmp    f0100d7c <debuginfo_eip+0x237>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100d5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d60:	eb 1a                	jmp    f0100d7c <debuginfo_eip+0x237>
f0100d62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d67:	eb 13                	jmp    f0100d7c <debuginfo_eip+0x237>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100d69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d6e:	eb 0c                	jmp    f0100d7c <debuginfo_eip+0x237>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if ( lline <= rline){
		info->eip_line = stabs[lline].n_desc;
	}
	else return -1;
f0100d70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d75:	eb 05                	jmp    f0100d7c <debuginfo_eip+0x237>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d77:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d7c:	83 c4 3c             	add    $0x3c,%esp
f0100d7f:	5b                   	pop    %ebx
f0100d80:	5e                   	pop    %esi
f0100d81:	5f                   	pop    %edi
f0100d82:	5d                   	pop    %ebp
f0100d83:	c3                   	ret    
f0100d84:	66 90                	xchg   %ax,%ax
f0100d86:	66 90                	xchg   %ax,%ax
f0100d88:	66 90                	xchg   %ax,%ax
f0100d8a:	66 90                	xchg   %ax,%ax
f0100d8c:	66 90                	xchg   %ax,%ax
f0100d8e:	66 90                	xchg   %ax,%ax

f0100d90 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d90:	55                   	push   %ebp
f0100d91:	89 e5                	mov    %esp,%ebp
f0100d93:	57                   	push   %edi
f0100d94:	56                   	push   %esi
f0100d95:	53                   	push   %ebx
f0100d96:	83 ec 3c             	sub    $0x3c,%esp
f0100d99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d9c:	89 d7                	mov    %edx,%edi
f0100d9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100da1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100da4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100da7:	89 c3                	mov    %eax,%ebx
f0100da9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100dac:	8b 45 10             	mov    0x10(%ebp),%eax
f0100daf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100db2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100db7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100dba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100dbd:	39 d9                	cmp    %ebx,%ecx
f0100dbf:	72 05                	jb     f0100dc6 <printnum+0x36>
f0100dc1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0100dc4:	77 69                	ja     f0100e2f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100dc6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0100dc9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0100dcd:	83 ee 01             	sub    $0x1,%esi
f0100dd0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100dd4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100dd8:	8b 44 24 08          	mov    0x8(%esp),%eax
f0100ddc:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0100de0:	89 c3                	mov    %eax,%ebx
f0100de2:	89 d6                	mov    %edx,%esi
f0100de4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100de7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100dea:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100dee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100df2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100df5:	89 04 24             	mov    %eax,(%esp)
f0100df8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100dfb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dff:	e8 0c 0a 00 00       	call   f0101810 <__udivdi3>
f0100e04:	89 d9                	mov    %ebx,%ecx
f0100e06:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100e0a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100e0e:	89 04 24             	mov    %eax,(%esp)
f0100e11:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100e15:	89 fa                	mov    %edi,%edx
f0100e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e1a:	e8 71 ff ff ff       	call   f0100d90 <printnum>
f0100e1f:	eb 1b                	jmp    f0100e3c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100e21:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e25:	8b 45 18             	mov    0x18(%ebp),%eax
f0100e28:	89 04 24             	mov    %eax,(%esp)
f0100e2b:	ff d3                	call   *%ebx
f0100e2d:	eb 03                	jmp    f0100e32 <printnum+0xa2>
f0100e2f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100e32:	83 ee 01             	sub    $0x1,%esi
f0100e35:	85 f6                	test   %esi,%esi
f0100e37:	7f e8                	jg     f0100e21 <printnum+0x91>
f0100e39:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100e3c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e40:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100e44:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e47:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e4a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e4e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100e52:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e55:	89 04 24             	mov    %eax,(%esp)
f0100e58:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e5b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e5f:	e8 dc 0a 00 00       	call   f0101940 <__umoddi3>
f0100e64:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e68:	0f be 80 69 20 10 f0 	movsbl -0xfefdf97(%eax),%eax
f0100e6f:	89 04 24             	mov    %eax,(%esp)
f0100e72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e75:	ff d0                	call   *%eax
}
f0100e77:	83 c4 3c             	add    $0x3c,%esp
f0100e7a:	5b                   	pop    %ebx
f0100e7b:	5e                   	pop    %esi
f0100e7c:	5f                   	pop    %edi
f0100e7d:	5d                   	pop    %ebp
f0100e7e:	c3                   	ret    

f0100e7f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100e7f:	55                   	push   %ebp
f0100e80:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100e82:	83 fa 01             	cmp    $0x1,%edx
f0100e85:	7e 0e                	jle    f0100e95 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100e87:	8b 10                	mov    (%eax),%edx
f0100e89:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100e8c:	89 08                	mov    %ecx,(%eax)
f0100e8e:	8b 02                	mov    (%edx),%eax
f0100e90:	8b 52 04             	mov    0x4(%edx),%edx
f0100e93:	eb 22                	jmp    f0100eb7 <getuint+0x38>
	else if (lflag)
f0100e95:	85 d2                	test   %edx,%edx
f0100e97:	74 10                	je     f0100ea9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100e99:	8b 10                	mov    (%eax),%edx
f0100e9b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100e9e:	89 08                	mov    %ecx,(%eax)
f0100ea0:	8b 02                	mov    (%edx),%eax
f0100ea2:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ea7:	eb 0e                	jmp    f0100eb7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100ea9:	8b 10                	mov    (%eax),%edx
f0100eab:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100eae:	89 08                	mov    %ecx,(%eax)
f0100eb0:	8b 02                	mov    (%edx),%eax
f0100eb2:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100eb7:	5d                   	pop    %ebp
f0100eb8:	c3                   	ret    

f0100eb9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100eb9:	55                   	push   %ebp
f0100eba:	89 e5                	mov    %esp,%ebp
f0100ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100ebf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100ec3:	8b 10                	mov    (%eax),%edx
f0100ec5:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ec8:	73 0a                	jae    f0100ed4 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100eca:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100ecd:	89 08                	mov    %ecx,(%eax)
f0100ecf:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ed2:	88 02                	mov    %al,(%edx)
}
f0100ed4:	5d                   	pop    %ebp
f0100ed5:	c3                   	ret    

f0100ed6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100ed6:	55                   	push   %ebp
f0100ed7:	89 e5                	mov    %esp,%ebp
f0100ed9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100edc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100edf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ee3:	8b 45 10             	mov    0x10(%ebp),%eax
f0100ee6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100eea:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100eed:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ef1:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ef4:	89 04 24             	mov    %eax,(%esp)
f0100ef7:	e8 02 00 00 00       	call   f0100efe <vprintfmt>
	va_end(ap);
}
f0100efc:	c9                   	leave  
f0100efd:	c3                   	ret    

f0100efe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100efe:	55                   	push   %ebp
f0100eff:	89 e5                	mov    %esp,%ebp
f0100f01:	57                   	push   %edi
f0100f02:	56                   	push   %esi
f0100f03:	53                   	push   %ebx
f0100f04:	83 ec 3c             	sub    $0x3c,%esp
f0100f07:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100f0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0100f0d:	eb 1e                	jmp    f0100f2d <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0'){
f0100f0f:	85 c0                	test   %eax,%eax
f0100f11:	75 0e                	jne    f0100f21 <vprintfmt+0x23>
				csa = 0x0700; //change color back
f0100f13:	66 c7 05 44 29 11 f0 	movw   $0x700,0xf0112944
f0100f1a:	00 07 
f0100f1c:	e9 f5 03 00 00       	jmp    f0101316 <vprintfmt+0x418>
				return;
			}
			putch(ch, putdat);
f0100f21:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100f25:	89 04 24             	mov    %eax,(%esp)
f0100f28:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100f2b:	89 f3                	mov    %esi,%ebx
f0100f2d:	8d 73 01             	lea    0x1(%ebx),%esi
f0100f30:	0f b6 03             	movzbl (%ebx),%eax
f0100f33:	83 f8 25             	cmp    $0x25,%eax
f0100f36:	75 d7                	jne    f0100f0f <vprintfmt+0x11>
f0100f38:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0100f3c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100f43:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0100f4a:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0100f51:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f56:	eb 1d                	jmp    f0100f75 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f58:	89 de                	mov    %ebx,%esi
      csa = num;
      break;

		// flag to pad on the right
		case '-':
			padc = '-';
f0100f5a:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0100f5e:	eb 15                	jmp    f0100f75 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f60:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100f62:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0100f66:	eb 0d                	jmp    f0100f75 <vprintfmt+0x77>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100f68:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f6b:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100f6e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f75:	8d 5e 01             	lea    0x1(%esi),%ebx
f0100f78:	0f b6 06             	movzbl (%esi),%eax
f0100f7b:	0f b6 c8             	movzbl %al,%ecx
f0100f7e:	83 e8 23             	sub    $0x23,%eax
f0100f81:	3c 55                	cmp    $0x55,%al
f0100f83:	0f 87 6d 03 00 00    	ja     f01012f6 <vprintfmt+0x3f8>
f0100f89:	0f b6 c0             	movzbl %al,%eax
f0100f8c:	ff 24 85 00 21 10 f0 	jmp    *-0xfefdf00(,%eax,4)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100f93:	83 fa 01             	cmp    $0x1,%edx
f0100f96:	7e 0d                	jle    f0100fa5 <vprintfmt+0xa7>
		return va_arg(*ap, long long);
f0100f98:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f9b:	8d 50 08             	lea    0x8(%eax),%edx
f0100f9e:	89 55 14             	mov    %edx,0x14(%ebp)
f0100fa1:	8b 00                	mov    (%eax),%eax
f0100fa3:	eb 1c                	jmp    f0100fc1 <vprintfmt+0xc3>
	else if (lflag)
f0100fa5:	85 d2                	test   %edx,%edx
f0100fa7:	74 0d                	je     f0100fb6 <vprintfmt+0xb8>
		return va_arg(*ap, long);
f0100fa9:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fac:	8d 50 04             	lea    0x4(%eax),%edx
f0100faf:	89 55 14             	mov    %edx,0x14(%ebp)
f0100fb2:	8b 00                	mov    (%eax),%eax
f0100fb4:	eb 0b                	jmp    f0100fc1 <vprintfmt+0xc3>
	else
		return va_arg(*ap, int);
f0100fb6:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fb9:	8d 50 04             	lea    0x4(%eax),%edx
f0100fbc:	89 55 14             	mov    %edx,0x14(%ebp)
f0100fbf:	8b 00                	mov    (%eax),%eax
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		case 'm': //change color
      num = getint(&ap, lflag);
      csa = num;
f0100fc1:	66 a3 44 29 11 f0    	mov    %ax,0xf0112944
      break;
f0100fc7:	e9 61 ff ff ff       	jmp    f0100f2d <vprintfmt+0x2f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fcc:	89 de                	mov    %ebx,%esi
f0100fce:	b8 00 00 00 00       	mov    $0x0,%eax
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100fd3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100fd6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100fda:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
f0100fdd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0100fe0:	83 fb 09             	cmp    $0x9,%ebx
f0100fe3:	77 3c                	ja     f0101021 <vprintfmt+0x123>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100fe5:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100fe8:	eb e9                	jmp    f0100fd3 <vprintfmt+0xd5>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100fea:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fed:	8d 48 04             	lea    0x4(%eax),%ecx
f0100ff0:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100ff3:	8b 00                	mov    (%eax),%eax
f0100ff5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ff8:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100ffa:	eb 28                	jmp    f0101024 <vprintfmt+0x126>
f0100ffc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100fff:	85 c9                	test   %ecx,%ecx
f0101001:	b8 00 00 00 00       	mov    $0x0,%eax
f0101006:	0f 49 c1             	cmovns %ecx,%eax
f0101009:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010100c:	89 de                	mov    %ebx,%esi
f010100e:	e9 62 ff ff ff       	jmp    f0100f75 <vprintfmt+0x77>
f0101013:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101015:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f010101c:	e9 54 ff ff ff       	jmp    f0100f75 <vprintfmt+0x77>
f0101021:	89 45 d4             	mov    %eax,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f0101024:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101028:	0f 89 47 ff ff ff    	jns    f0100f75 <vprintfmt+0x77>
f010102e:	e9 35 ff ff ff       	jmp    f0100f68 <vprintfmt+0x6a>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101033:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101036:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0101038:	e9 38 ff ff ff       	jmp    f0100f75 <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010103d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101040:	8d 50 04             	lea    0x4(%eax),%edx
f0101043:	89 55 14             	mov    %edx,0x14(%ebp)
f0101046:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010104a:	8b 00                	mov    (%eax),%eax
f010104c:	89 04 24             	mov    %eax,(%esp)
f010104f:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101052:	e9 d6 fe ff ff       	jmp    f0100f2d <vprintfmt+0x2f>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101057:	8b 45 14             	mov    0x14(%ebp),%eax
f010105a:	8d 50 04             	lea    0x4(%eax),%edx
f010105d:	89 55 14             	mov    %edx,0x14(%ebp)
f0101060:	8b 00                	mov    (%eax),%eax
f0101062:	99                   	cltd   
f0101063:	31 d0                	xor    %edx,%eax
f0101065:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101067:	83 f8 07             	cmp    $0x7,%eax
f010106a:	7f 0b                	jg     f0101077 <vprintfmt+0x179>
f010106c:	8b 14 85 60 22 10 f0 	mov    -0xfefdda0(,%eax,4),%edx
f0101073:	85 d2                	test   %edx,%edx
f0101075:	75 20                	jne    f0101097 <vprintfmt+0x199>
				printfmt(putch, putdat, "error %d", err);
f0101077:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010107b:	c7 44 24 08 81 20 10 	movl   $0xf0102081,0x8(%esp)
f0101082:	f0 
f0101083:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101087:	8b 45 08             	mov    0x8(%ebp),%eax
f010108a:	89 04 24             	mov    %eax,(%esp)
f010108d:	e8 44 fe ff ff       	call   f0100ed6 <printfmt>
f0101092:	e9 96 fe ff ff       	jmp    f0100f2d <vprintfmt+0x2f>
			else
				printfmt(putch, putdat, "%s", p);
f0101097:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010109b:	c7 44 24 08 82 22 10 	movl   $0xf0102282,0x8(%esp)
f01010a2:	f0 
f01010a3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01010aa:	89 04 24             	mov    %eax,(%esp)
f01010ad:	e8 24 fe ff ff       	call   f0100ed6 <printfmt>
f01010b2:	e9 76 fe ff ff       	jmp    f0100f2d <vprintfmt+0x2f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010b7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01010ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01010bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01010c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c3:	8d 50 04             	lea    0x4(%eax),%edx
f01010c6:	89 55 14             	mov    %edx,0x14(%ebp)
f01010c9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f01010cb:	85 f6                	test   %esi,%esi
f01010cd:	b8 7a 20 10 f0       	mov    $0xf010207a,%eax
f01010d2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f01010d5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f01010d9:	0f 84 97 00 00 00    	je     f0101176 <vprintfmt+0x278>
f01010df:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01010e3:	0f 8e 9b 00 00 00    	jle    f0101184 <vprintfmt+0x286>
				for (width -= strnlen(p, precision); width > 0; width--)
f01010e9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01010ed:	89 34 24             	mov    %esi,(%esp)
f01010f0:	e8 a3 03 00 00       	call   f0101498 <strnlen>
f01010f5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01010f8:	29 c1                	sub    %eax,%ecx
f01010fa:	89 4d d0             	mov    %ecx,-0x30(%ebp)
					putch(padc, putdat);
f01010fd:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0101101:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101104:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0101107:	8b 75 08             	mov    0x8(%ebp),%esi
f010110a:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010110d:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010110f:	eb 0f                	jmp    f0101120 <vprintfmt+0x222>
					putch(padc, putdat);
f0101111:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101115:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101118:	89 04 24             	mov    %eax,(%esp)
f010111b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010111d:	83 eb 01             	sub    $0x1,%ebx
f0101120:	85 db                	test   %ebx,%ebx
f0101122:	7f ed                	jg     f0101111 <vprintfmt+0x213>
f0101124:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0101127:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010112a:	85 c9                	test   %ecx,%ecx
f010112c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101131:	0f 49 c1             	cmovns %ecx,%eax
f0101134:	29 c1                	sub    %eax,%ecx
f0101136:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101139:	89 cf                	mov    %ecx,%edi
f010113b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010113e:	eb 50                	jmp    f0101190 <vprintfmt+0x292>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101140:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101144:	74 1e                	je     f0101164 <vprintfmt+0x266>
f0101146:	0f be d2             	movsbl %dl,%edx
f0101149:	83 ea 20             	sub    $0x20,%edx
f010114c:	83 fa 5e             	cmp    $0x5e,%edx
f010114f:	76 13                	jbe    f0101164 <vprintfmt+0x266>
					putch('?', putdat);
f0101151:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101154:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101158:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010115f:	ff 55 08             	call   *0x8(%ebp)
f0101162:	eb 0d                	jmp    f0101171 <vprintfmt+0x273>
				else
					putch(ch, putdat);
f0101164:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101167:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010116b:	89 04 24             	mov    %eax,(%esp)
f010116e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101171:	83 ef 01             	sub    $0x1,%edi
f0101174:	eb 1a                	jmp    f0101190 <vprintfmt+0x292>
f0101176:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101179:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010117c:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010117f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101182:	eb 0c                	jmp    f0101190 <vprintfmt+0x292>
f0101184:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101187:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010118a:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010118d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101190:	83 c6 01             	add    $0x1,%esi
f0101193:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f0101197:	0f be c2             	movsbl %dl,%eax
f010119a:	85 c0                	test   %eax,%eax
f010119c:	74 27                	je     f01011c5 <vprintfmt+0x2c7>
f010119e:	85 db                	test   %ebx,%ebx
f01011a0:	78 9e                	js     f0101140 <vprintfmt+0x242>
f01011a2:	83 eb 01             	sub    $0x1,%ebx
f01011a5:	79 99                	jns    f0101140 <vprintfmt+0x242>
f01011a7:	89 f8                	mov    %edi,%eax
f01011a9:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01011ac:	8b 75 08             	mov    0x8(%ebp),%esi
f01011af:	89 c3                	mov    %eax,%ebx
f01011b1:	eb 1a                	jmp    f01011cd <vprintfmt+0x2cf>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01011b3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01011b7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01011be:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01011c0:	83 eb 01             	sub    $0x1,%ebx
f01011c3:	eb 08                	jmp    f01011cd <vprintfmt+0x2cf>
f01011c5:	89 fb                	mov    %edi,%ebx
f01011c7:	8b 75 08             	mov    0x8(%ebp),%esi
f01011ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01011cd:	85 db                	test   %ebx,%ebx
f01011cf:	7f e2                	jg     f01011b3 <vprintfmt+0x2b5>
f01011d1:	89 75 08             	mov    %esi,0x8(%ebp)
f01011d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01011d7:	e9 51 fd ff ff       	jmp    f0100f2d <vprintfmt+0x2f>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01011dc:	83 fa 01             	cmp    $0x1,%edx
f01011df:	7e 16                	jle    f01011f7 <vprintfmt+0x2f9>
		return va_arg(*ap, long long);
f01011e1:	8b 45 14             	mov    0x14(%ebp),%eax
f01011e4:	8d 50 08             	lea    0x8(%eax),%edx
f01011e7:	89 55 14             	mov    %edx,0x14(%ebp)
f01011ea:	8b 50 04             	mov    0x4(%eax),%edx
f01011ed:	8b 00                	mov    (%eax),%eax
f01011ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01011f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01011f5:	eb 32                	jmp    f0101229 <vprintfmt+0x32b>
	else if (lflag)
f01011f7:	85 d2                	test   %edx,%edx
f01011f9:	74 18                	je     f0101213 <vprintfmt+0x315>
		return va_arg(*ap, long);
f01011fb:	8b 45 14             	mov    0x14(%ebp),%eax
f01011fe:	8d 50 04             	lea    0x4(%eax),%edx
f0101201:	89 55 14             	mov    %edx,0x14(%ebp)
f0101204:	8b 30                	mov    (%eax),%esi
f0101206:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0101209:	89 f0                	mov    %esi,%eax
f010120b:	c1 f8 1f             	sar    $0x1f,%eax
f010120e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101211:	eb 16                	jmp    f0101229 <vprintfmt+0x32b>
	else
		return va_arg(*ap, int);
f0101213:	8b 45 14             	mov    0x14(%ebp),%eax
f0101216:	8d 50 04             	lea    0x4(%eax),%edx
f0101219:	89 55 14             	mov    %edx,0x14(%ebp)
f010121c:	8b 30                	mov    (%eax),%esi
f010121e:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0101221:	89 f0                	mov    %esi,%eax
f0101223:	c1 f8 1f             	sar    $0x1f,%eax
f0101226:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101229:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010122c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010122f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101234:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101238:	0f 89 80 00 00 00    	jns    f01012be <vprintfmt+0x3c0>
				putch('-', putdat);
f010123e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101242:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101249:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010124c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010124f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101252:	f7 d8                	neg    %eax
f0101254:	83 d2 00             	adc    $0x0,%edx
f0101257:	f7 da                	neg    %edx
			}
			base = 10;
f0101259:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010125e:	eb 5e                	jmp    f01012be <vprintfmt+0x3c0>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101260:	8d 45 14             	lea    0x14(%ebp),%eax
f0101263:	e8 17 fc ff ff       	call   f0100e7f <getuint>
			base = 10;
f0101268:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010126d:	eb 4f                	jmp    f01012be <vprintfmt+0x3c0>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f010126f:	8d 45 14             	lea    0x14(%ebp),%eax
f0101272:	e8 08 fc ff ff       	call   f0100e7f <getuint>
      base = 8;
f0101277:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
f010127c:	eb 40                	jmp    f01012be <vprintfmt+0x3c0>

		// pointer
		case 'p':
			putch('0', putdat);
f010127e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101282:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101289:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010128c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101290:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0101297:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010129a:	8b 45 14             	mov    0x14(%ebp),%eax
f010129d:	8d 50 04             	lea    0x4(%eax),%edx
f01012a0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01012a3:	8b 00                	mov    (%eax),%eax
f01012a5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01012aa:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01012af:	eb 0d                	jmp    f01012be <vprintfmt+0x3c0>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01012b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01012b4:	e8 c6 fb ff ff       	call   f0100e7f <getuint>
			base = 16;
f01012b9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01012be:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f01012c2:	89 74 24 10          	mov    %esi,0x10(%esp)
f01012c6:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01012c9:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01012cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01012d1:	89 04 24             	mov    %eax,(%esp)
f01012d4:	89 54 24 04          	mov    %edx,0x4(%esp)
f01012d8:	89 fa                	mov    %edi,%edx
f01012da:	8b 45 08             	mov    0x8(%ebp),%eax
f01012dd:	e8 ae fa ff ff       	call   f0100d90 <printnum>
			break;
f01012e2:	e9 46 fc ff ff       	jmp    f0100f2d <vprintfmt+0x2f>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01012e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012eb:	89 0c 24             	mov    %ecx,(%esp)
f01012ee:	ff 55 08             	call   *0x8(%ebp)
			break;
f01012f1:	e9 37 fc ff ff       	jmp    f0100f2d <vprintfmt+0x2f>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01012f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012fa:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101301:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101304:	89 f3                	mov    %esi,%ebx
f0101306:	eb 03                	jmp    f010130b <vprintfmt+0x40d>
f0101308:	83 eb 01             	sub    $0x1,%ebx
f010130b:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f010130f:	75 f7                	jne    f0101308 <vprintfmt+0x40a>
f0101311:	e9 17 fc ff ff       	jmp    f0100f2d <vprintfmt+0x2f>
				/* do nothing */;
			break;
		}
	}
}
f0101316:	83 c4 3c             	add    $0x3c,%esp
f0101319:	5b                   	pop    %ebx
f010131a:	5e                   	pop    %esi
f010131b:	5f                   	pop    %edi
f010131c:	5d                   	pop    %ebp
f010131d:	c3                   	ret    

f010131e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010131e:	55                   	push   %ebp
f010131f:	89 e5                	mov    %esp,%ebp
f0101321:	83 ec 28             	sub    $0x28,%esp
f0101324:	8b 45 08             	mov    0x8(%ebp),%eax
f0101327:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010132a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010132d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101331:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101334:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010133b:	85 c0                	test   %eax,%eax
f010133d:	74 30                	je     f010136f <vsnprintf+0x51>
f010133f:	85 d2                	test   %edx,%edx
f0101341:	7e 2c                	jle    f010136f <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101343:	8b 45 14             	mov    0x14(%ebp),%eax
f0101346:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010134a:	8b 45 10             	mov    0x10(%ebp),%eax
f010134d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101351:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101354:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101358:	c7 04 24 b9 0e 10 f0 	movl   $0xf0100eb9,(%esp)
f010135f:	e8 9a fb ff ff       	call   f0100efe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101364:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101367:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010136a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010136d:	eb 05                	jmp    f0101374 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010136f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101374:	c9                   	leave  
f0101375:	c3                   	ret    

f0101376 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101376:	55                   	push   %ebp
f0101377:	89 e5                	mov    %esp,%ebp
f0101379:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010137c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010137f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101383:	8b 45 10             	mov    0x10(%ebp),%eax
f0101386:	89 44 24 08          	mov    %eax,0x8(%esp)
f010138a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010138d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101391:	8b 45 08             	mov    0x8(%ebp),%eax
f0101394:	89 04 24             	mov    %eax,(%esp)
f0101397:	e8 82 ff ff ff       	call   f010131e <vsnprintf>
	va_end(ap);

	return rc;
}
f010139c:	c9                   	leave  
f010139d:	c3                   	ret    
f010139e:	66 90                	xchg   %ax,%ax

f01013a0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01013a0:	55                   	push   %ebp
f01013a1:	89 e5                	mov    %esp,%ebp
f01013a3:	57                   	push   %edi
f01013a4:	56                   	push   %esi
f01013a5:	53                   	push   %ebx
f01013a6:	83 ec 1c             	sub    $0x1c,%esp
f01013a9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01013ac:	85 c0                	test   %eax,%eax
f01013ae:	74 18                	je     f01013c8 <readline+0x28>
		cprintf("%m%s", 0x0400 ,  prompt);
f01013b0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01013b4:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f01013bb:	00 
f01013bc:	c7 04 24 80 22 10 f0 	movl   $0xf0102280,(%esp)
f01013c3:	e8 86 f6 ff ff       	call   f0100a4e <cprintf>

	i = 0;
	echoing = iscons(0);
f01013c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013cf:	e8 b7 f2 ff ff       	call   f010068b <iscons>
f01013d4:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%m%s", 0x0400 ,  prompt);

	i = 0;
f01013d6:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01013db:	e8 9a f2 ff ff       	call   f010067a <getchar>
f01013e0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01013e2:	85 c0                	test   %eax,%eax
f01013e4:	79 17                	jns    f01013fd <readline+0x5d>
			cprintf("read error: %e\n", c);
f01013e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013ea:	c7 04 24 85 22 10 f0 	movl   $0xf0102285,(%esp)
f01013f1:	e8 58 f6 ff ff       	call   f0100a4e <cprintf>
			return NULL;
f01013f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01013fb:	eb 70                	jmp    f010146d <readline+0xcd>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01013fd:	83 f8 7f             	cmp    $0x7f,%eax
f0101400:	74 05                	je     f0101407 <readline+0x67>
f0101402:	83 f8 08             	cmp    $0x8,%eax
f0101405:	75 1c                	jne    f0101423 <readline+0x83>
f0101407:	85 f6                	test   %esi,%esi
f0101409:	7e 18                	jle    f0101423 <readline+0x83>
			if (echoing)
f010140b:	85 ff                	test   %edi,%edi
f010140d:	8d 76 00             	lea    0x0(%esi),%esi
f0101410:	74 0c                	je     f010141e <readline+0x7e>
				cputchar('\b');
f0101412:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0101419:	e8 4c f2 ff ff       	call   f010066a <cputchar>
			i--;
f010141e:	83 ee 01             	sub    $0x1,%esi
f0101421:	eb b8                	jmp    f01013db <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101423:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101429:	7f 1c                	jg     f0101447 <readline+0xa7>
f010142b:	83 fb 1f             	cmp    $0x1f,%ebx
f010142e:	7e 17                	jle    f0101447 <readline+0xa7>
			if (echoing)
f0101430:	85 ff                	test   %edi,%edi
f0101432:	74 08                	je     f010143c <readline+0x9c>
				cputchar(c);
f0101434:	89 1c 24             	mov    %ebx,(%esp)
f0101437:	e8 2e f2 ff ff       	call   f010066a <cputchar>
			buf[i++] = c;
f010143c:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101442:	8d 76 01             	lea    0x1(%esi),%esi
f0101445:	eb 94                	jmp    f01013db <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
f0101447:	83 fb 0d             	cmp    $0xd,%ebx
f010144a:	74 05                	je     f0101451 <readline+0xb1>
f010144c:	83 fb 0a             	cmp    $0xa,%ebx
f010144f:	75 8a                	jne    f01013db <readline+0x3b>
			if (echoing)
f0101451:	85 ff                	test   %edi,%edi
f0101453:	74 0c                	je     f0101461 <readline+0xc1>
				cputchar('\n');
f0101455:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010145c:	e8 09 f2 ff ff       	call   f010066a <cputchar>
			buf[i] = 0;
f0101461:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f0101468:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f010146d:	83 c4 1c             	add    $0x1c,%esp
f0101470:	5b                   	pop    %ebx
f0101471:	5e                   	pop    %esi
f0101472:	5f                   	pop    %edi
f0101473:	5d                   	pop    %ebp
f0101474:	c3                   	ret    
f0101475:	66 90                	xchg   %ax,%ax
f0101477:	66 90                	xchg   %ax,%ax
f0101479:	66 90                	xchg   %ax,%ax
f010147b:	66 90                	xchg   %ax,%ax
f010147d:	66 90                	xchg   %ax,%ax
f010147f:	90                   	nop

f0101480 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101480:	55                   	push   %ebp
f0101481:	89 e5                	mov    %esp,%ebp
f0101483:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101486:	b8 00 00 00 00       	mov    $0x0,%eax
f010148b:	eb 03                	jmp    f0101490 <strlen+0x10>
		n++;
f010148d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101490:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101494:	75 f7                	jne    f010148d <strlen+0xd>
		n++;
	return n;
}
f0101496:	5d                   	pop    %ebp
f0101497:	c3                   	ret    

f0101498 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101498:	55                   	push   %ebp
f0101499:	89 e5                	mov    %esp,%ebp
f010149b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010149e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01014a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01014a6:	eb 03                	jmp    f01014ab <strnlen+0x13>
		n++;
f01014a8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01014ab:	39 d0                	cmp    %edx,%eax
f01014ad:	74 06                	je     f01014b5 <strnlen+0x1d>
f01014af:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01014b3:	75 f3                	jne    f01014a8 <strnlen+0x10>
		n++;
	return n;
}
f01014b5:	5d                   	pop    %ebp
f01014b6:	c3                   	ret    

f01014b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01014b7:	55                   	push   %ebp
f01014b8:	89 e5                	mov    %esp,%ebp
f01014ba:	53                   	push   %ebx
f01014bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01014be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01014c1:	89 c2                	mov    %eax,%edx
f01014c3:	83 c2 01             	add    $0x1,%edx
f01014c6:	83 c1 01             	add    $0x1,%ecx
f01014c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01014cd:	88 5a ff             	mov    %bl,-0x1(%edx)
f01014d0:	84 db                	test   %bl,%bl
f01014d2:	75 ef                	jne    f01014c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01014d4:	5b                   	pop    %ebx
f01014d5:	5d                   	pop    %ebp
f01014d6:	c3                   	ret    

f01014d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01014d7:	55                   	push   %ebp
f01014d8:	89 e5                	mov    %esp,%ebp
f01014da:	53                   	push   %ebx
f01014db:	83 ec 08             	sub    $0x8,%esp
f01014de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01014e1:	89 1c 24             	mov    %ebx,(%esp)
f01014e4:	e8 97 ff ff ff       	call   f0101480 <strlen>
	strcpy(dst + len, src);
f01014e9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014ec:	89 54 24 04          	mov    %edx,0x4(%esp)
f01014f0:	01 d8                	add    %ebx,%eax
f01014f2:	89 04 24             	mov    %eax,(%esp)
f01014f5:	e8 bd ff ff ff       	call   f01014b7 <strcpy>
	return dst;
}
f01014fa:	89 d8                	mov    %ebx,%eax
f01014fc:	83 c4 08             	add    $0x8,%esp
f01014ff:	5b                   	pop    %ebx
f0101500:	5d                   	pop    %ebp
f0101501:	c3                   	ret    

f0101502 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101502:	55                   	push   %ebp
f0101503:	89 e5                	mov    %esp,%ebp
f0101505:	56                   	push   %esi
f0101506:	53                   	push   %ebx
f0101507:	8b 75 08             	mov    0x8(%ebp),%esi
f010150a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010150d:	89 f3                	mov    %esi,%ebx
f010150f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101512:	89 f2                	mov    %esi,%edx
f0101514:	eb 0f                	jmp    f0101525 <strncpy+0x23>
		*dst++ = *src;
f0101516:	83 c2 01             	add    $0x1,%edx
f0101519:	0f b6 01             	movzbl (%ecx),%eax
f010151c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010151f:	80 39 01             	cmpb   $0x1,(%ecx)
f0101522:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101525:	39 da                	cmp    %ebx,%edx
f0101527:	75 ed                	jne    f0101516 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101529:	89 f0                	mov    %esi,%eax
f010152b:	5b                   	pop    %ebx
f010152c:	5e                   	pop    %esi
f010152d:	5d                   	pop    %ebp
f010152e:	c3                   	ret    

f010152f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010152f:	55                   	push   %ebp
f0101530:	89 e5                	mov    %esp,%ebp
f0101532:	56                   	push   %esi
f0101533:	53                   	push   %ebx
f0101534:	8b 75 08             	mov    0x8(%ebp),%esi
f0101537:	8b 55 0c             	mov    0xc(%ebp),%edx
f010153a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010153d:	89 f0                	mov    %esi,%eax
f010153f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101543:	85 c9                	test   %ecx,%ecx
f0101545:	75 0b                	jne    f0101552 <strlcpy+0x23>
f0101547:	eb 1d                	jmp    f0101566 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101549:	83 c0 01             	add    $0x1,%eax
f010154c:	83 c2 01             	add    $0x1,%edx
f010154f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101552:	39 d8                	cmp    %ebx,%eax
f0101554:	74 0b                	je     f0101561 <strlcpy+0x32>
f0101556:	0f b6 0a             	movzbl (%edx),%ecx
f0101559:	84 c9                	test   %cl,%cl
f010155b:	75 ec                	jne    f0101549 <strlcpy+0x1a>
f010155d:	89 c2                	mov    %eax,%edx
f010155f:	eb 02                	jmp    f0101563 <strlcpy+0x34>
f0101561:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0101563:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0101566:	29 f0                	sub    %esi,%eax
}
f0101568:	5b                   	pop    %ebx
f0101569:	5e                   	pop    %esi
f010156a:	5d                   	pop    %ebp
f010156b:	c3                   	ret    

f010156c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010156c:	55                   	push   %ebp
f010156d:	89 e5                	mov    %esp,%ebp
f010156f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101572:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101575:	eb 06                	jmp    f010157d <strcmp+0x11>
		p++, q++;
f0101577:	83 c1 01             	add    $0x1,%ecx
f010157a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010157d:	0f b6 01             	movzbl (%ecx),%eax
f0101580:	84 c0                	test   %al,%al
f0101582:	74 04                	je     f0101588 <strcmp+0x1c>
f0101584:	3a 02                	cmp    (%edx),%al
f0101586:	74 ef                	je     f0101577 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101588:	0f b6 c0             	movzbl %al,%eax
f010158b:	0f b6 12             	movzbl (%edx),%edx
f010158e:	29 d0                	sub    %edx,%eax
}
f0101590:	5d                   	pop    %ebp
f0101591:	c3                   	ret    

f0101592 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101592:	55                   	push   %ebp
f0101593:	89 e5                	mov    %esp,%ebp
f0101595:	53                   	push   %ebx
f0101596:	8b 45 08             	mov    0x8(%ebp),%eax
f0101599:	8b 55 0c             	mov    0xc(%ebp),%edx
f010159c:	89 c3                	mov    %eax,%ebx
f010159e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01015a1:	eb 06                	jmp    f01015a9 <strncmp+0x17>
		n--, p++, q++;
f01015a3:	83 c0 01             	add    $0x1,%eax
f01015a6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01015a9:	39 d8                	cmp    %ebx,%eax
f01015ab:	74 15                	je     f01015c2 <strncmp+0x30>
f01015ad:	0f b6 08             	movzbl (%eax),%ecx
f01015b0:	84 c9                	test   %cl,%cl
f01015b2:	74 04                	je     f01015b8 <strncmp+0x26>
f01015b4:	3a 0a                	cmp    (%edx),%cl
f01015b6:	74 eb                	je     f01015a3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01015b8:	0f b6 00             	movzbl (%eax),%eax
f01015bb:	0f b6 12             	movzbl (%edx),%edx
f01015be:	29 d0                	sub    %edx,%eax
f01015c0:	eb 05                	jmp    f01015c7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01015c2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01015c7:	5b                   	pop    %ebx
f01015c8:	5d                   	pop    %ebp
f01015c9:	c3                   	ret    

f01015ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01015ca:	55                   	push   %ebp
f01015cb:	89 e5                	mov    %esp,%ebp
f01015cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01015d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01015d4:	eb 07                	jmp    f01015dd <strchr+0x13>
		if (*s == c)
f01015d6:	38 ca                	cmp    %cl,%dl
f01015d8:	74 0f                	je     f01015e9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01015da:	83 c0 01             	add    $0x1,%eax
f01015dd:	0f b6 10             	movzbl (%eax),%edx
f01015e0:	84 d2                	test   %dl,%dl
f01015e2:	75 f2                	jne    f01015d6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01015e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015e9:	5d                   	pop    %ebp
f01015ea:	c3                   	ret    

f01015eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01015eb:	55                   	push   %ebp
f01015ec:	89 e5                	mov    %esp,%ebp
f01015ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01015f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01015f5:	eb 07                	jmp    f01015fe <strfind+0x13>
		if (*s == c)
f01015f7:	38 ca                	cmp    %cl,%dl
f01015f9:	74 0a                	je     f0101605 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01015fb:	83 c0 01             	add    $0x1,%eax
f01015fe:	0f b6 10             	movzbl (%eax),%edx
f0101601:	84 d2                	test   %dl,%dl
f0101603:	75 f2                	jne    f01015f7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0101605:	5d                   	pop    %ebp
f0101606:	c3                   	ret    

f0101607 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101607:	55                   	push   %ebp
f0101608:	89 e5                	mov    %esp,%ebp
f010160a:	57                   	push   %edi
f010160b:	56                   	push   %esi
f010160c:	53                   	push   %ebx
f010160d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101610:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101613:	85 c9                	test   %ecx,%ecx
f0101615:	74 36                	je     f010164d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101617:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010161d:	75 28                	jne    f0101647 <memset+0x40>
f010161f:	f6 c1 03             	test   $0x3,%cl
f0101622:	75 23                	jne    f0101647 <memset+0x40>
		c &= 0xFF;
f0101624:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101628:	89 d3                	mov    %edx,%ebx
f010162a:	c1 e3 08             	shl    $0x8,%ebx
f010162d:	89 d6                	mov    %edx,%esi
f010162f:	c1 e6 18             	shl    $0x18,%esi
f0101632:	89 d0                	mov    %edx,%eax
f0101634:	c1 e0 10             	shl    $0x10,%eax
f0101637:	09 f0                	or     %esi,%eax
f0101639:	09 c2                	or     %eax,%edx
f010163b:	89 d0                	mov    %edx,%eax
f010163d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010163f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101642:	fc                   	cld    
f0101643:	f3 ab                	rep stos %eax,%es:(%edi)
f0101645:	eb 06                	jmp    f010164d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101647:	8b 45 0c             	mov    0xc(%ebp),%eax
f010164a:	fc                   	cld    
f010164b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010164d:	89 f8                	mov    %edi,%eax
f010164f:	5b                   	pop    %ebx
f0101650:	5e                   	pop    %esi
f0101651:	5f                   	pop    %edi
f0101652:	5d                   	pop    %ebp
f0101653:	c3                   	ret    

f0101654 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101654:	55                   	push   %ebp
f0101655:	89 e5                	mov    %esp,%ebp
f0101657:	57                   	push   %edi
f0101658:	56                   	push   %esi
f0101659:	8b 45 08             	mov    0x8(%ebp),%eax
f010165c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010165f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101662:	39 c6                	cmp    %eax,%esi
f0101664:	73 35                	jae    f010169b <memmove+0x47>
f0101666:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101669:	39 d0                	cmp    %edx,%eax
f010166b:	73 2e                	jae    f010169b <memmove+0x47>
		s += n;
		d += n;
f010166d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0101670:	89 d6                	mov    %edx,%esi
f0101672:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101674:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010167a:	75 13                	jne    f010168f <memmove+0x3b>
f010167c:	f6 c1 03             	test   $0x3,%cl
f010167f:	75 0e                	jne    f010168f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101681:	83 ef 04             	sub    $0x4,%edi
f0101684:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101687:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010168a:	fd                   	std    
f010168b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010168d:	eb 09                	jmp    f0101698 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010168f:	83 ef 01             	sub    $0x1,%edi
f0101692:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101695:	fd                   	std    
f0101696:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101698:	fc                   	cld    
f0101699:	eb 1d                	jmp    f01016b8 <memmove+0x64>
f010169b:	89 f2                	mov    %esi,%edx
f010169d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010169f:	f6 c2 03             	test   $0x3,%dl
f01016a2:	75 0f                	jne    f01016b3 <memmove+0x5f>
f01016a4:	f6 c1 03             	test   $0x3,%cl
f01016a7:	75 0a                	jne    f01016b3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01016a9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01016ac:	89 c7                	mov    %eax,%edi
f01016ae:	fc                   	cld    
f01016af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01016b1:	eb 05                	jmp    f01016b8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01016b3:	89 c7                	mov    %eax,%edi
f01016b5:	fc                   	cld    
f01016b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01016b8:	5e                   	pop    %esi
f01016b9:	5f                   	pop    %edi
f01016ba:	5d                   	pop    %ebp
f01016bb:	c3                   	ret    

f01016bc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01016bc:	55                   	push   %ebp
f01016bd:	89 e5                	mov    %esp,%ebp
f01016bf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01016c2:	8b 45 10             	mov    0x10(%ebp),%eax
f01016c5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01016c9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01016d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01016d3:	89 04 24             	mov    %eax,(%esp)
f01016d6:	e8 79 ff ff ff       	call   f0101654 <memmove>
}
f01016db:	c9                   	leave  
f01016dc:	c3                   	ret    

f01016dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01016dd:	55                   	push   %ebp
f01016de:	89 e5                	mov    %esp,%ebp
f01016e0:	56                   	push   %esi
f01016e1:	53                   	push   %ebx
f01016e2:	8b 55 08             	mov    0x8(%ebp),%edx
f01016e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01016e8:	89 d6                	mov    %edx,%esi
f01016ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01016ed:	eb 1a                	jmp    f0101709 <memcmp+0x2c>
		if (*s1 != *s2)
f01016ef:	0f b6 02             	movzbl (%edx),%eax
f01016f2:	0f b6 19             	movzbl (%ecx),%ebx
f01016f5:	38 d8                	cmp    %bl,%al
f01016f7:	74 0a                	je     f0101703 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01016f9:	0f b6 c0             	movzbl %al,%eax
f01016fc:	0f b6 db             	movzbl %bl,%ebx
f01016ff:	29 d8                	sub    %ebx,%eax
f0101701:	eb 0f                	jmp    f0101712 <memcmp+0x35>
		s1++, s2++;
f0101703:	83 c2 01             	add    $0x1,%edx
f0101706:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101709:	39 f2                	cmp    %esi,%edx
f010170b:	75 e2                	jne    f01016ef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010170d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101712:	5b                   	pop    %ebx
f0101713:	5e                   	pop    %esi
f0101714:	5d                   	pop    %ebp
f0101715:	c3                   	ret    

f0101716 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101716:	55                   	push   %ebp
f0101717:	89 e5                	mov    %esp,%ebp
f0101719:	8b 45 08             	mov    0x8(%ebp),%eax
f010171c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010171f:	89 c2                	mov    %eax,%edx
f0101721:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101724:	eb 07                	jmp    f010172d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101726:	38 08                	cmp    %cl,(%eax)
f0101728:	74 07                	je     f0101731 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010172a:	83 c0 01             	add    $0x1,%eax
f010172d:	39 d0                	cmp    %edx,%eax
f010172f:	72 f5                	jb     f0101726 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101731:	5d                   	pop    %ebp
f0101732:	c3                   	ret    

f0101733 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101733:	55                   	push   %ebp
f0101734:	89 e5                	mov    %esp,%ebp
f0101736:	57                   	push   %edi
f0101737:	56                   	push   %esi
f0101738:	53                   	push   %ebx
f0101739:	8b 55 08             	mov    0x8(%ebp),%edx
f010173c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010173f:	eb 03                	jmp    f0101744 <strtol+0x11>
		s++;
f0101741:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101744:	0f b6 0a             	movzbl (%edx),%ecx
f0101747:	80 f9 09             	cmp    $0x9,%cl
f010174a:	74 f5                	je     f0101741 <strtol+0xe>
f010174c:	80 f9 20             	cmp    $0x20,%cl
f010174f:	74 f0                	je     f0101741 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101751:	80 f9 2b             	cmp    $0x2b,%cl
f0101754:	75 0a                	jne    f0101760 <strtol+0x2d>
		s++;
f0101756:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101759:	bf 00 00 00 00       	mov    $0x0,%edi
f010175e:	eb 11                	jmp    f0101771 <strtol+0x3e>
f0101760:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101765:	80 f9 2d             	cmp    $0x2d,%cl
f0101768:	75 07                	jne    f0101771 <strtol+0x3e>
		s++, neg = 1;
f010176a:	8d 52 01             	lea    0x1(%edx),%edx
f010176d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101771:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0101776:	75 15                	jne    f010178d <strtol+0x5a>
f0101778:	80 3a 30             	cmpb   $0x30,(%edx)
f010177b:	75 10                	jne    f010178d <strtol+0x5a>
f010177d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101781:	75 0a                	jne    f010178d <strtol+0x5a>
		s += 2, base = 16;
f0101783:	83 c2 02             	add    $0x2,%edx
f0101786:	b8 10 00 00 00       	mov    $0x10,%eax
f010178b:	eb 10                	jmp    f010179d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f010178d:	85 c0                	test   %eax,%eax
f010178f:	75 0c                	jne    f010179d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101791:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101793:	80 3a 30             	cmpb   $0x30,(%edx)
f0101796:	75 05                	jne    f010179d <strtol+0x6a>
		s++, base = 8;
f0101798:	83 c2 01             	add    $0x1,%edx
f010179b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f010179d:	bb 00 00 00 00       	mov    $0x0,%ebx
f01017a2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01017a5:	0f b6 0a             	movzbl (%edx),%ecx
f01017a8:	8d 71 d0             	lea    -0x30(%ecx),%esi
f01017ab:	89 f0                	mov    %esi,%eax
f01017ad:	3c 09                	cmp    $0x9,%al
f01017af:	77 08                	ja     f01017b9 <strtol+0x86>
			dig = *s - '0';
f01017b1:	0f be c9             	movsbl %cl,%ecx
f01017b4:	83 e9 30             	sub    $0x30,%ecx
f01017b7:	eb 20                	jmp    f01017d9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f01017b9:	8d 71 9f             	lea    -0x61(%ecx),%esi
f01017bc:	89 f0                	mov    %esi,%eax
f01017be:	3c 19                	cmp    $0x19,%al
f01017c0:	77 08                	ja     f01017ca <strtol+0x97>
			dig = *s - 'a' + 10;
f01017c2:	0f be c9             	movsbl %cl,%ecx
f01017c5:	83 e9 57             	sub    $0x57,%ecx
f01017c8:	eb 0f                	jmp    f01017d9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f01017ca:	8d 71 bf             	lea    -0x41(%ecx),%esi
f01017cd:	89 f0                	mov    %esi,%eax
f01017cf:	3c 19                	cmp    $0x19,%al
f01017d1:	77 16                	ja     f01017e9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f01017d3:	0f be c9             	movsbl %cl,%ecx
f01017d6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01017d9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01017dc:	7d 0f                	jge    f01017ed <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f01017de:	83 c2 01             	add    $0x1,%edx
f01017e1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f01017e5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f01017e7:	eb bc                	jmp    f01017a5 <strtol+0x72>
f01017e9:	89 d8                	mov    %ebx,%eax
f01017eb:	eb 02                	jmp    f01017ef <strtol+0xbc>
f01017ed:	89 d8                	mov    %ebx,%eax

	if (endptr)
f01017ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01017f3:	74 05                	je     f01017fa <strtol+0xc7>
		*endptr = (char *) s;
f01017f5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017f8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01017fa:	f7 d8                	neg    %eax
f01017fc:	85 ff                	test   %edi,%edi
f01017fe:	0f 44 c3             	cmove  %ebx,%eax
}
f0101801:	5b                   	pop    %ebx
f0101802:	5e                   	pop    %esi
f0101803:	5f                   	pop    %edi
f0101804:	5d                   	pop    %ebp
f0101805:	c3                   	ret    
f0101806:	66 90                	xchg   %ax,%ax
f0101808:	66 90                	xchg   %ax,%ax
f010180a:	66 90                	xchg   %ax,%ax
f010180c:	66 90                	xchg   %ax,%ax
f010180e:	66 90                	xchg   %ax,%ax

f0101810 <__udivdi3>:
f0101810:	55                   	push   %ebp
f0101811:	57                   	push   %edi
f0101812:	56                   	push   %esi
f0101813:	83 ec 0c             	sub    $0xc,%esp
f0101816:	8b 44 24 28          	mov    0x28(%esp),%eax
f010181a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010181e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0101822:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0101826:	85 c0                	test   %eax,%eax
f0101828:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010182c:	89 ea                	mov    %ebp,%edx
f010182e:	89 0c 24             	mov    %ecx,(%esp)
f0101831:	75 2d                	jne    f0101860 <__udivdi3+0x50>
f0101833:	39 e9                	cmp    %ebp,%ecx
f0101835:	77 61                	ja     f0101898 <__udivdi3+0x88>
f0101837:	85 c9                	test   %ecx,%ecx
f0101839:	89 ce                	mov    %ecx,%esi
f010183b:	75 0b                	jne    f0101848 <__udivdi3+0x38>
f010183d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101842:	31 d2                	xor    %edx,%edx
f0101844:	f7 f1                	div    %ecx
f0101846:	89 c6                	mov    %eax,%esi
f0101848:	31 d2                	xor    %edx,%edx
f010184a:	89 e8                	mov    %ebp,%eax
f010184c:	f7 f6                	div    %esi
f010184e:	89 c5                	mov    %eax,%ebp
f0101850:	89 f8                	mov    %edi,%eax
f0101852:	f7 f6                	div    %esi
f0101854:	89 ea                	mov    %ebp,%edx
f0101856:	83 c4 0c             	add    $0xc,%esp
f0101859:	5e                   	pop    %esi
f010185a:	5f                   	pop    %edi
f010185b:	5d                   	pop    %ebp
f010185c:	c3                   	ret    
f010185d:	8d 76 00             	lea    0x0(%esi),%esi
f0101860:	39 e8                	cmp    %ebp,%eax
f0101862:	77 24                	ja     f0101888 <__udivdi3+0x78>
f0101864:	0f bd e8             	bsr    %eax,%ebp
f0101867:	83 f5 1f             	xor    $0x1f,%ebp
f010186a:	75 3c                	jne    f01018a8 <__udivdi3+0x98>
f010186c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101870:	39 34 24             	cmp    %esi,(%esp)
f0101873:	0f 86 9f 00 00 00    	jbe    f0101918 <__udivdi3+0x108>
f0101879:	39 d0                	cmp    %edx,%eax
f010187b:	0f 82 97 00 00 00    	jb     f0101918 <__udivdi3+0x108>
f0101881:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101888:	31 d2                	xor    %edx,%edx
f010188a:	31 c0                	xor    %eax,%eax
f010188c:	83 c4 0c             	add    $0xc,%esp
f010188f:	5e                   	pop    %esi
f0101890:	5f                   	pop    %edi
f0101891:	5d                   	pop    %ebp
f0101892:	c3                   	ret    
f0101893:	90                   	nop
f0101894:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101898:	89 f8                	mov    %edi,%eax
f010189a:	f7 f1                	div    %ecx
f010189c:	31 d2                	xor    %edx,%edx
f010189e:	83 c4 0c             	add    $0xc,%esp
f01018a1:	5e                   	pop    %esi
f01018a2:	5f                   	pop    %edi
f01018a3:	5d                   	pop    %ebp
f01018a4:	c3                   	ret    
f01018a5:	8d 76 00             	lea    0x0(%esi),%esi
f01018a8:	89 e9                	mov    %ebp,%ecx
f01018aa:	8b 3c 24             	mov    (%esp),%edi
f01018ad:	d3 e0                	shl    %cl,%eax
f01018af:	89 c6                	mov    %eax,%esi
f01018b1:	b8 20 00 00 00       	mov    $0x20,%eax
f01018b6:	29 e8                	sub    %ebp,%eax
f01018b8:	89 c1                	mov    %eax,%ecx
f01018ba:	d3 ef                	shr    %cl,%edi
f01018bc:	89 e9                	mov    %ebp,%ecx
f01018be:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01018c2:	8b 3c 24             	mov    (%esp),%edi
f01018c5:	09 74 24 08          	or     %esi,0x8(%esp)
f01018c9:	89 d6                	mov    %edx,%esi
f01018cb:	d3 e7                	shl    %cl,%edi
f01018cd:	89 c1                	mov    %eax,%ecx
f01018cf:	89 3c 24             	mov    %edi,(%esp)
f01018d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01018d6:	d3 ee                	shr    %cl,%esi
f01018d8:	89 e9                	mov    %ebp,%ecx
f01018da:	d3 e2                	shl    %cl,%edx
f01018dc:	89 c1                	mov    %eax,%ecx
f01018de:	d3 ef                	shr    %cl,%edi
f01018e0:	09 d7                	or     %edx,%edi
f01018e2:	89 f2                	mov    %esi,%edx
f01018e4:	89 f8                	mov    %edi,%eax
f01018e6:	f7 74 24 08          	divl   0x8(%esp)
f01018ea:	89 d6                	mov    %edx,%esi
f01018ec:	89 c7                	mov    %eax,%edi
f01018ee:	f7 24 24             	mull   (%esp)
f01018f1:	39 d6                	cmp    %edx,%esi
f01018f3:	89 14 24             	mov    %edx,(%esp)
f01018f6:	72 30                	jb     f0101928 <__udivdi3+0x118>
f01018f8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01018fc:	89 e9                	mov    %ebp,%ecx
f01018fe:	d3 e2                	shl    %cl,%edx
f0101900:	39 c2                	cmp    %eax,%edx
f0101902:	73 05                	jae    f0101909 <__udivdi3+0xf9>
f0101904:	3b 34 24             	cmp    (%esp),%esi
f0101907:	74 1f                	je     f0101928 <__udivdi3+0x118>
f0101909:	89 f8                	mov    %edi,%eax
f010190b:	31 d2                	xor    %edx,%edx
f010190d:	e9 7a ff ff ff       	jmp    f010188c <__udivdi3+0x7c>
f0101912:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101918:	31 d2                	xor    %edx,%edx
f010191a:	b8 01 00 00 00       	mov    $0x1,%eax
f010191f:	e9 68 ff ff ff       	jmp    f010188c <__udivdi3+0x7c>
f0101924:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101928:	8d 47 ff             	lea    -0x1(%edi),%eax
f010192b:	31 d2                	xor    %edx,%edx
f010192d:	83 c4 0c             	add    $0xc,%esp
f0101930:	5e                   	pop    %esi
f0101931:	5f                   	pop    %edi
f0101932:	5d                   	pop    %ebp
f0101933:	c3                   	ret    
f0101934:	66 90                	xchg   %ax,%ax
f0101936:	66 90                	xchg   %ax,%ax
f0101938:	66 90                	xchg   %ax,%ax
f010193a:	66 90                	xchg   %ax,%ax
f010193c:	66 90                	xchg   %ax,%ax
f010193e:	66 90                	xchg   %ax,%ax

f0101940 <__umoddi3>:
f0101940:	55                   	push   %ebp
f0101941:	57                   	push   %edi
f0101942:	56                   	push   %esi
f0101943:	83 ec 14             	sub    $0x14,%esp
f0101946:	8b 44 24 28          	mov    0x28(%esp),%eax
f010194a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010194e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0101952:	89 c7                	mov    %eax,%edi
f0101954:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101958:	8b 44 24 30          	mov    0x30(%esp),%eax
f010195c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0101960:	89 34 24             	mov    %esi,(%esp)
f0101963:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101967:	85 c0                	test   %eax,%eax
f0101969:	89 c2                	mov    %eax,%edx
f010196b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010196f:	75 17                	jne    f0101988 <__umoddi3+0x48>
f0101971:	39 fe                	cmp    %edi,%esi
f0101973:	76 4b                	jbe    f01019c0 <__umoddi3+0x80>
f0101975:	89 c8                	mov    %ecx,%eax
f0101977:	89 fa                	mov    %edi,%edx
f0101979:	f7 f6                	div    %esi
f010197b:	89 d0                	mov    %edx,%eax
f010197d:	31 d2                	xor    %edx,%edx
f010197f:	83 c4 14             	add    $0x14,%esp
f0101982:	5e                   	pop    %esi
f0101983:	5f                   	pop    %edi
f0101984:	5d                   	pop    %ebp
f0101985:	c3                   	ret    
f0101986:	66 90                	xchg   %ax,%ax
f0101988:	39 f8                	cmp    %edi,%eax
f010198a:	77 54                	ja     f01019e0 <__umoddi3+0xa0>
f010198c:	0f bd e8             	bsr    %eax,%ebp
f010198f:	83 f5 1f             	xor    $0x1f,%ebp
f0101992:	75 5c                	jne    f01019f0 <__umoddi3+0xb0>
f0101994:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101998:	39 3c 24             	cmp    %edi,(%esp)
f010199b:	0f 87 e7 00 00 00    	ja     f0101a88 <__umoddi3+0x148>
f01019a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01019a5:	29 f1                	sub    %esi,%ecx
f01019a7:	19 c7                	sbb    %eax,%edi
f01019a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01019ad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01019b1:	8b 44 24 08          	mov    0x8(%esp),%eax
f01019b5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01019b9:	83 c4 14             	add    $0x14,%esp
f01019bc:	5e                   	pop    %esi
f01019bd:	5f                   	pop    %edi
f01019be:	5d                   	pop    %ebp
f01019bf:	c3                   	ret    
f01019c0:	85 f6                	test   %esi,%esi
f01019c2:	89 f5                	mov    %esi,%ebp
f01019c4:	75 0b                	jne    f01019d1 <__umoddi3+0x91>
f01019c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01019cb:	31 d2                	xor    %edx,%edx
f01019cd:	f7 f6                	div    %esi
f01019cf:	89 c5                	mov    %eax,%ebp
f01019d1:	8b 44 24 04          	mov    0x4(%esp),%eax
f01019d5:	31 d2                	xor    %edx,%edx
f01019d7:	f7 f5                	div    %ebp
f01019d9:	89 c8                	mov    %ecx,%eax
f01019db:	f7 f5                	div    %ebp
f01019dd:	eb 9c                	jmp    f010197b <__umoddi3+0x3b>
f01019df:	90                   	nop
f01019e0:	89 c8                	mov    %ecx,%eax
f01019e2:	89 fa                	mov    %edi,%edx
f01019e4:	83 c4 14             	add    $0x14,%esp
f01019e7:	5e                   	pop    %esi
f01019e8:	5f                   	pop    %edi
f01019e9:	5d                   	pop    %ebp
f01019ea:	c3                   	ret    
f01019eb:	90                   	nop
f01019ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019f0:	8b 04 24             	mov    (%esp),%eax
f01019f3:	be 20 00 00 00       	mov    $0x20,%esi
f01019f8:	89 e9                	mov    %ebp,%ecx
f01019fa:	29 ee                	sub    %ebp,%esi
f01019fc:	d3 e2                	shl    %cl,%edx
f01019fe:	89 f1                	mov    %esi,%ecx
f0101a00:	d3 e8                	shr    %cl,%eax
f0101a02:	89 e9                	mov    %ebp,%ecx
f0101a04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a08:	8b 04 24             	mov    (%esp),%eax
f0101a0b:	09 54 24 04          	or     %edx,0x4(%esp)
f0101a0f:	89 fa                	mov    %edi,%edx
f0101a11:	d3 e0                	shl    %cl,%eax
f0101a13:	89 f1                	mov    %esi,%ecx
f0101a15:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a19:	8b 44 24 10          	mov    0x10(%esp),%eax
f0101a1d:	d3 ea                	shr    %cl,%edx
f0101a1f:	89 e9                	mov    %ebp,%ecx
f0101a21:	d3 e7                	shl    %cl,%edi
f0101a23:	89 f1                	mov    %esi,%ecx
f0101a25:	d3 e8                	shr    %cl,%eax
f0101a27:	89 e9                	mov    %ebp,%ecx
f0101a29:	09 f8                	or     %edi,%eax
f0101a2b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0101a2f:	f7 74 24 04          	divl   0x4(%esp)
f0101a33:	d3 e7                	shl    %cl,%edi
f0101a35:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101a39:	89 d7                	mov    %edx,%edi
f0101a3b:	f7 64 24 08          	mull   0x8(%esp)
f0101a3f:	39 d7                	cmp    %edx,%edi
f0101a41:	89 c1                	mov    %eax,%ecx
f0101a43:	89 14 24             	mov    %edx,(%esp)
f0101a46:	72 2c                	jb     f0101a74 <__umoddi3+0x134>
f0101a48:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0101a4c:	72 22                	jb     f0101a70 <__umoddi3+0x130>
f0101a4e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101a52:	29 c8                	sub    %ecx,%eax
f0101a54:	19 d7                	sbb    %edx,%edi
f0101a56:	89 e9                	mov    %ebp,%ecx
f0101a58:	89 fa                	mov    %edi,%edx
f0101a5a:	d3 e8                	shr    %cl,%eax
f0101a5c:	89 f1                	mov    %esi,%ecx
f0101a5e:	d3 e2                	shl    %cl,%edx
f0101a60:	89 e9                	mov    %ebp,%ecx
f0101a62:	d3 ef                	shr    %cl,%edi
f0101a64:	09 d0                	or     %edx,%eax
f0101a66:	89 fa                	mov    %edi,%edx
f0101a68:	83 c4 14             	add    $0x14,%esp
f0101a6b:	5e                   	pop    %esi
f0101a6c:	5f                   	pop    %edi
f0101a6d:	5d                   	pop    %ebp
f0101a6e:	c3                   	ret    
f0101a6f:	90                   	nop
f0101a70:	39 d7                	cmp    %edx,%edi
f0101a72:	75 da                	jne    f0101a4e <__umoddi3+0x10e>
f0101a74:	8b 14 24             	mov    (%esp),%edx
f0101a77:	89 c1                	mov    %eax,%ecx
f0101a79:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0101a7d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0101a81:	eb cb                	jmp    f0101a4e <__umoddi3+0x10e>
f0101a83:	90                   	nop
f0101a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101a88:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0101a8c:	0f 82 0f ff ff ff    	jb     f01019a1 <__umoddi3+0x61>
f0101a92:	e9 1a ff ff ff       	jmp    f01019b1 <__umoddi3+0x71>

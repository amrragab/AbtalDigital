
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
f010004e:	c7 04 24 80 19 10 f0 	movl   $0xf0101980,(%esp)
f0100055:	e8 37 09 00 00       	call   f0100991 <cprintf>
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
f0100082:	e8 28 07 00 00       	call   f01007af <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 9c 19 10 f0 	movl   $0xf010199c,(%esp)
f0100092:	e8 fa 08 00 00       	call   f0100991 <cprintf>
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
f01000c0:	e8 22 14 00 00       	call   f01014e7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 b5 04 00 00       	call   f010057f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 b7 19 10 f0 	movl   $0xf01019b7,(%esp)
f01000d9:	e8 b3 08 00 00       	call   f0100991 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000de:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000e5:	e8 56 ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000f1:	e8 c3 06 00 00       	call   f01007b9 <monitor>
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
f0100125:	c7 04 24 d2 19 10 f0 	movl   $0xf01019d2,(%esp)
f010012c:	e8 60 08 00 00       	call   f0100991 <cprintf>
	vcprintf(fmt, ap);
f0100131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100135:	89 34 24             	mov    %esi,(%esp)
f0100138:	e8 21 08 00 00       	call   f010095e <vcprintf>
	cprintf("\n");
f010013d:	c7 04 24 0e 1a 10 f0 	movl   $0xf0101a0e,(%esp)
f0100144:	e8 48 08 00 00       	call   f0100991 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100150:	e8 64 06 00 00       	call   f01007b9 <monitor>
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
f010016f:	c7 04 24 ea 19 10 f0 	movl   $0xf01019ea,(%esp)
f0100176:	e8 16 08 00 00       	call   f0100991 <cprintf>
	vcprintf(fmt, ap);
f010017b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010017f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100182:	89 04 24             	mov    %eax,(%esp)
f0100185:	e8 d4 07 00 00       	call   f010095e <vcprintf>
	cprintf("\n");
f010018a:	c7 04 24 0e 1a 10 f0 	movl   $0xf0101a0e,(%esp)
f0100191:	e8 fb 07 00 00       	call   f0100991 <cprintf>
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
f0100245:	0f b6 82 60 1b 10 f0 	movzbl -0xfefe4a0(%edx),%eax
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
f0100282:	0f b6 82 60 1b 10 f0 	movzbl -0xfefe4a0(%edx),%eax
f0100289:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
	shift ^= togglecode[data];
f010028f:	0f b6 8a 60 1a 10 f0 	movzbl -0xfefe5a0(%edx),%ecx
f0100296:	31 c8                	xor    %ecx,%eax
f0100298:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f010029d:	89 c1                	mov    %eax,%ecx
f010029f:	83 e1 03             	and    $0x3,%ecx
f01002a2:	8b 0c 8d 40 1a 10 f0 	mov    -0xfefe5c0(,%ecx,4),%ecx
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
f01002e2:	c7 04 24 04 1a 10 f0 	movl   $0xf0101a04,(%esp)
f01002e9:	e8 a3 06 00 00       	call   f0100991 <cprintf>
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
f01004a9:	e8 86 10 00 00       	call   f0101534 <memmove>
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
f0100656:	c7 04 24 10 1a 10 f0 	movl   $0xf0101a10,(%esp)
f010065d:	e8 2f 03 00 00       	call   f0100991 <cprintf>
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
f01006a6:	c7 44 24 08 60 1c 10 	movl   $0xf0101c60,0x8(%esp)
f01006ad:	f0 
f01006ae:	c7 44 24 04 7e 1c 10 	movl   $0xf0101c7e,0x4(%esp)
f01006b5:	f0 
f01006b6:	c7 04 24 83 1c 10 f0 	movl   $0xf0101c83,(%esp)
f01006bd:	e8 cf 02 00 00       	call   f0100991 <cprintf>
f01006c2:	c7 44 24 08 24 1d 10 	movl   $0xf0101d24,0x8(%esp)
f01006c9:	f0 
f01006ca:	c7 44 24 04 8c 1c 10 	movl   $0xf0101c8c,0x4(%esp)
f01006d1:	f0 
f01006d2:	c7 04 24 83 1c 10 f0 	movl   $0xf0101c83,(%esp)
f01006d9:	e8 b3 02 00 00       	call   f0100991 <cprintf>
	return 0;
}
f01006de:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e3:	c9                   	leave  
f01006e4:	c3                   	ret    

f01006e5 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006e5:	55                   	push   %ebp
f01006e6:	89 e5                	mov    %esp,%ebp
f01006e8:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006eb:	c7 04 24 95 1c 10 f0 	movl   $0xf0101c95,(%esp)
f01006f2:	e8 9a 02 00 00       	call   f0100991 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006f7:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01006fe:	00 
f01006ff:	c7 04 24 4c 1d 10 f0 	movl   $0xf0101d4c,(%esp)
f0100706:	e8 86 02 00 00       	call   f0100991 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010070b:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100712:	00 
f0100713:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010071a:	f0 
f010071b:	c7 04 24 74 1d 10 f0 	movl   $0xf0101d74,(%esp)
f0100722:	e8 6a 02 00 00       	call   f0100991 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100727:	c7 44 24 08 77 19 10 	movl   $0x101977,0x8(%esp)
f010072e:	00 
f010072f:	c7 44 24 04 77 19 10 	movl   $0xf0101977,0x4(%esp)
f0100736:	f0 
f0100737:	c7 04 24 98 1d 10 f0 	movl   $0xf0101d98,(%esp)
f010073e:	e8 4e 02 00 00       	call   f0100991 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100743:	c7 44 24 08 00 23 11 	movl   $0x112300,0x8(%esp)
f010074a:	00 
f010074b:	c7 44 24 04 00 23 11 	movl   $0xf0112300,0x4(%esp)
f0100752:	f0 
f0100753:	c7 04 24 bc 1d 10 f0 	movl   $0xf0101dbc,(%esp)
f010075a:	e8 32 02 00 00       	call   f0100991 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010075f:	c7 44 24 08 46 29 11 	movl   $0x112946,0x8(%esp)
f0100766:	00 
f0100767:	c7 44 24 04 46 29 11 	movl   $0xf0112946,0x4(%esp)
f010076e:	f0 
f010076f:	c7 04 24 e0 1d 10 f0 	movl   $0xf0101de0,(%esp)
f0100776:	e8 16 02 00 00       	call   f0100991 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010077b:	b8 45 2d 11 f0       	mov    $0xf0112d45,%eax
f0100780:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100785:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010078a:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100790:	85 c0                	test   %eax,%eax
f0100792:	0f 48 c2             	cmovs  %edx,%eax
f0100795:	c1 f8 0a             	sar    $0xa,%eax
f0100798:	89 44 24 04          	mov    %eax,0x4(%esp)
f010079c:	c7 04 24 04 1e 10 f0 	movl   $0xf0101e04,(%esp)
f01007a3:	e8 e9 01 00 00       	call   f0100991 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01007a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ad:	c9                   	leave  
f01007ae:	c3                   	ret    

f01007af <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01007af:	55                   	push   %ebp
f01007b0:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f01007b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b7:	5d                   	pop    %ebp
f01007b8:	c3                   	ret    

f01007b9 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007b9:	55                   	push   %ebp
f01007ba:	89 e5                	mov    %esp,%ebp
f01007bc:	57                   	push   %edi
f01007bd:	56                   	push   %esi
f01007be:	53                   	push   %ebx
f01007bf:	83 ec 6c             	sub    $0x6c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007c2:	c7 04 24 30 1e 10 f0 	movl   $0xf0101e30,(%esp)
f01007c9:	e8 c3 01 00 00       	call   f0100991 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007ce:	c7 04 24 54 1e 10 f0 	movl   $0xf0101e54,(%esp)
f01007d5:	e8 b7 01 00 00       	call   f0100991 <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n", 
f01007da:	c7 44 24 18 ae 1c 10 	movl   $0xf0101cae,0x18(%esp)
f01007e1:	f0 
f01007e2:	c7 44 24 14 00 04 00 	movl   $0x400,0x14(%esp)
f01007e9:	00 
f01007ea:	c7 44 24 10 b2 1c 10 	movl   $0xf0101cb2,0x10(%esp)
f01007f1:	f0 
f01007f2:	c7 44 24 0c 00 02 00 	movl   $0x200,0xc(%esp)
f01007f9:	00 
f01007fa:	c7 44 24 08 b8 1c 10 	movl   $0xf0101cb8,0x8(%esp)
f0100801:	f0 
f0100802:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
f0100809:	00 
f010080a:	c7 04 24 bd 1c 10 f0 	movl   $0xf0101cbd,(%esp)
f0100811:	e8 7b 01 00 00       	call   f0100991 <cprintf>
    0x0100, "blue", 0x0200, "green", 0x0400, "red");

	cprintf("x=%d y=%d\n", 3);
f0100816:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010081d:	00 
f010081e:	c7 04 24 cd 1c 10 f0 	movl   $0xf0101ccd,(%esp)
f0100825:	e8 67 01 00 00       	call   f0100991 <cprintf>

	while (1) {
		buf = readline("AbtalELDigital> ");
f010082a:	c7 04 24 d8 1c 10 f0 	movl   $0xf0101cd8,(%esp)
f0100831:	e8 4a 0a 00 00       	call   f0101280 <readline>
f0100836:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100838:	85 c0                	test   %eax,%eax
f010083a:	74 ee                	je     f010082a <monitor+0x71>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010083c:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100843:	be 00 00 00 00       	mov    $0x0,%esi
f0100848:	eb 0a                	jmp    f0100854 <monitor+0x9b>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010084a:	c6 03 00             	movb   $0x0,(%ebx)
f010084d:	89 f7                	mov    %esi,%edi
f010084f:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100852:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100854:	0f b6 03             	movzbl (%ebx),%eax
f0100857:	84 c0                	test   %al,%al
f0100859:	74 63                	je     f01008be <monitor+0x105>
f010085b:	0f be c0             	movsbl %al,%eax
f010085e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100862:	c7 04 24 e9 1c 10 f0 	movl   $0xf0101ce9,(%esp)
f0100869:	e8 3c 0c 00 00       	call   f01014aa <strchr>
f010086e:	85 c0                	test   %eax,%eax
f0100870:	75 d8                	jne    f010084a <monitor+0x91>
			*buf++ = 0;
		if (*buf == 0)
f0100872:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100875:	74 47                	je     f01008be <monitor+0x105>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100877:	83 fe 0f             	cmp    $0xf,%esi
f010087a:	75 16                	jne    f0100892 <monitor+0xd9>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010087c:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100883:	00 
f0100884:	c7 04 24 ee 1c 10 f0 	movl   $0xf0101cee,(%esp)
f010088b:	e8 01 01 00 00       	call   f0100991 <cprintf>
f0100890:	eb 98                	jmp    f010082a <monitor+0x71>
			return 0;
		}
		argv[argc++] = buf;
f0100892:	8d 7e 01             	lea    0x1(%esi),%edi
f0100895:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100899:	eb 03                	jmp    f010089e <monitor+0xe5>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010089b:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010089e:	0f b6 03             	movzbl (%ebx),%eax
f01008a1:	84 c0                	test   %al,%al
f01008a3:	74 ad                	je     f0100852 <monitor+0x99>
f01008a5:	0f be c0             	movsbl %al,%eax
f01008a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ac:	c7 04 24 e9 1c 10 f0 	movl   $0xf0101ce9,(%esp)
f01008b3:	e8 f2 0b 00 00       	call   f01014aa <strchr>
f01008b8:	85 c0                	test   %eax,%eax
f01008ba:	74 df                	je     f010089b <monitor+0xe2>
f01008bc:	eb 94                	jmp    f0100852 <monitor+0x99>
			buf++;
	}
	argv[argc] = 0;
f01008be:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008c5:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008c6:	85 f6                	test   %esi,%esi
f01008c8:	0f 84 5c ff ff ff    	je     f010082a <monitor+0x71>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008ce:	c7 44 24 04 7e 1c 10 	movl   $0xf0101c7e,0x4(%esp)
f01008d5:	f0 
f01008d6:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008d9:	89 04 24             	mov    %eax,(%esp)
f01008dc:	e8 6b 0b 00 00       	call   f010144c <strcmp>
f01008e1:	85 c0                	test   %eax,%eax
f01008e3:	74 1b                	je     f0100900 <monitor+0x147>
f01008e5:	c7 44 24 04 8c 1c 10 	movl   $0xf0101c8c,0x4(%esp)
f01008ec:	f0 
f01008ed:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008f0:	89 04 24             	mov    %eax,(%esp)
f01008f3:	e8 54 0b 00 00       	call   f010144c <strcmp>
f01008f8:	85 c0                	test   %eax,%eax
f01008fa:	75 2f                	jne    f010092b <monitor+0x172>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008fc:	b0 01                	mov    $0x1,%al
f01008fe:	eb 05                	jmp    f0100905 <monitor+0x14c>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100900:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100905:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100908:	01 d0                	add    %edx,%eax
f010090a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010090d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100911:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100914:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100918:	89 34 24             	mov    %esi,(%esp)
f010091b:	ff 14 85 84 1e 10 f0 	call   *-0xfefe17c(,%eax,4)
	cprintf("x=%d y=%d\n", 3);

	while (1) {
		buf = readline("AbtalELDigital> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100922:	85 c0                	test   %eax,%eax
f0100924:	78 1d                	js     f0100943 <monitor+0x18a>
f0100926:	e9 ff fe ff ff       	jmp    f010082a <monitor+0x71>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010092b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010092e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100932:	c7 04 24 0b 1d 10 f0 	movl   $0xf0101d0b,(%esp)
f0100939:	e8 53 00 00 00       	call   f0100991 <cprintf>
f010093e:	e9 e7 fe ff ff       	jmp    f010082a <monitor+0x71>
		buf = readline("AbtalELDigital> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100943:	83 c4 6c             	add    $0x6c,%esp
f0100946:	5b                   	pop    %ebx
f0100947:	5e                   	pop    %esi
f0100948:	5f                   	pop    %edi
f0100949:	5d                   	pop    %ebp
f010094a:	c3                   	ret    

f010094b <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010094b:	55                   	push   %ebp
f010094c:	89 e5                	mov    %esp,%ebp
f010094e:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100951:	8b 45 08             	mov    0x8(%ebp),%eax
f0100954:	89 04 24             	mov    %eax,(%esp)
f0100957:	e8 0e fd ff ff       	call   f010066a <cputchar>
	*cnt++;
}
f010095c:	c9                   	leave  
f010095d:	c3                   	ret    

f010095e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010095e:	55                   	push   %ebp
f010095f:	89 e5                	mov    %esp,%ebp
f0100961:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100964:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap); // send numofper
f010096b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010096e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100972:	8b 45 08             	mov    0x8(%ebp),%eax
f0100975:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100979:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010097c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100980:	c7 04 24 4b 09 10 f0 	movl   $0xf010094b,(%esp)
f0100987:	e8 52 04 00 00       	call   f0100dde <vprintfmt>
	return cnt;
}
f010098c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010098f:	c9                   	leave  
f0100990:	c3                   	ret    

f0100991 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100991:	55                   	push   %ebp
f0100992:	89 e5                	mov    %esp,%ebp
f0100994:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	// loop over fmt, count all % -- 
	va_start(ap, fmt);
f0100997:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap); // send numofper
f010099a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010099e:	8b 45 08             	mov    0x8(%ebp),%eax
f01009a1:	89 04 24             	mov    %eax,(%esp)
f01009a4:	e8 b5 ff ff ff       	call   f010095e <vcprintf>
	va_end(ap);

	return cnt;
}
f01009a9:	c9                   	leave  
f01009aa:	c3                   	ret    

f01009ab <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009ab:	55                   	push   %ebp
f01009ac:	89 e5                	mov    %esp,%ebp
f01009ae:	57                   	push   %edi
f01009af:	56                   	push   %esi
f01009b0:	53                   	push   %ebx
f01009b1:	83 ec 10             	sub    $0x10,%esp
f01009b4:	89 c6                	mov    %eax,%esi
f01009b6:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01009b9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01009bc:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009bf:	8b 1a                	mov    (%edx),%ebx
f01009c1:	8b 01                	mov    (%ecx),%eax
f01009c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009c6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f01009cd:	eb 77                	jmp    f0100a46 <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f01009cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009d2:	01 d8                	add    %ebx,%eax
f01009d4:	b9 02 00 00 00       	mov    $0x2,%ecx
f01009d9:	99                   	cltd   
f01009da:	f7 f9                	idiv   %ecx
f01009dc:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009de:	eb 01                	jmp    f01009e1 <stab_binsearch+0x36>
			m--;
f01009e0:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009e1:	39 d9                	cmp    %ebx,%ecx
f01009e3:	7c 1d                	jl     f0100a02 <stab_binsearch+0x57>
f01009e5:	6b d1 0c             	imul   $0xc,%ecx,%edx
f01009e8:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f01009ed:	39 fa                	cmp    %edi,%edx
f01009ef:	75 ef                	jne    f01009e0 <stab_binsearch+0x35>
f01009f1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009f4:	6b d1 0c             	imul   $0xc,%ecx,%edx
f01009f7:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f01009fb:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01009fe:	73 18                	jae    f0100a18 <stab_binsearch+0x6d>
f0100a00:	eb 05                	jmp    f0100a07 <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a02:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f0100a05:	eb 3f                	jmp    f0100a46 <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100a07:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100a0a:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0100a0c:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a0f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100a16:	eb 2e                	jmp    f0100a46 <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a18:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a1b:	73 15                	jae    f0100a32 <stab_binsearch+0x87>
			*region_right = m - 1;
f0100a1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100a20:	48                   	dec    %eax
f0100a21:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a24:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100a27:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a29:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100a30:	eb 14                	jmp    f0100a46 <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a32:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100a35:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0100a38:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0100a3a:	ff 45 0c             	incl   0xc(%ebp)
f0100a3d:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a3f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a46:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a49:	7e 84                	jle    f01009cf <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a4b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100a4f:	75 0d                	jne    f0100a5e <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0100a51:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100a54:	8b 00                	mov    (%eax),%eax
f0100a56:	48                   	dec    %eax
f0100a57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100a5a:	89 07                	mov    %eax,(%edi)
f0100a5c:	eb 22                	jmp    f0100a80 <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a61:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a63:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100a66:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a68:	eb 01                	jmp    f0100a6b <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a6a:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a6b:	39 c1                	cmp    %eax,%ecx
f0100a6d:	7d 0c                	jge    f0100a7b <stab_binsearch+0xd0>
f0100a6f:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0100a72:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100a77:	39 fa                	cmp    %edi,%edx
f0100a79:	75 ef                	jne    f0100a6a <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a7b:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0100a7e:	89 07                	mov    %eax,(%edi)
	}
}
f0100a80:	83 c4 10             	add    $0x10,%esp
f0100a83:	5b                   	pop    %ebx
f0100a84:	5e                   	pop    %esi
f0100a85:	5f                   	pop    %edi
f0100a86:	5d                   	pop    %ebp
f0100a87:	c3                   	ret    

f0100a88 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a88:	55                   	push   %ebp
f0100a89:	89 e5                	mov    %esp,%ebp
f0100a8b:	57                   	push   %edi
f0100a8c:	56                   	push   %esi
f0100a8d:	53                   	push   %ebx
f0100a8e:	83 ec 2c             	sub    $0x2c,%esp
f0100a91:	8b 75 08             	mov    0x8(%ebp),%esi
f0100a94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a97:	c7 03 94 1e 10 f0    	movl   $0xf0101e94,(%ebx)
	info->eip_line = 0;
f0100a9d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100aa4:	c7 43 08 94 1e 10 f0 	movl   $0xf0101e94,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100aab:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100ab2:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100ab5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100abc:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100ac2:	76 12                	jbe    f0100ad6 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ac4:	b8 c6 72 10 f0       	mov    $0xf01072c6,%eax
f0100ac9:	3d c9 59 10 f0       	cmp    $0xf01059c9,%eax
f0100ace:	0f 86 6b 01 00 00    	jbe    f0100c3f <debuginfo_eip+0x1b7>
f0100ad4:	eb 1c                	jmp    f0100af2 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100ad6:	c7 44 24 08 9e 1e 10 	movl   $0xf0101e9e,0x8(%esp)
f0100add:	f0 
f0100ade:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100ae5:	00 
f0100ae6:	c7 04 24 ab 1e 10 f0 	movl   $0xf0101eab,(%esp)
f0100aed:	e8 06 f6 ff ff       	call   f01000f8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100af2:	80 3d c5 72 10 f0 00 	cmpb   $0x0,0xf01072c5
f0100af9:	0f 85 47 01 00 00    	jne    f0100c46 <debuginfo_eip+0x1be>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100aff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b06:	b8 c8 59 10 f0       	mov    $0xf01059c8,%eax
f0100b0b:	2d f8 20 10 f0       	sub    $0xf01020f8,%eax
f0100b10:	c1 f8 02             	sar    $0x2,%eax
f0100b13:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b19:	83 e8 01             	sub    $0x1,%eax
f0100b1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b1f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b23:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100b2a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b2d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b30:	b8 f8 20 10 f0       	mov    $0xf01020f8,%eax
f0100b35:	e8 71 fe ff ff       	call   f01009ab <stab_binsearch>
	if (lfile == 0)
f0100b3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b3d:	85 c0                	test   %eax,%eax
f0100b3f:	0f 84 08 01 00 00    	je     f0100c4d <debuginfo_eip+0x1c5>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b45:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b48:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b4e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b52:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100b59:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b5c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b5f:	b8 f8 20 10 f0       	mov    $0xf01020f8,%eax
f0100b64:	e8 42 fe ff ff       	call   f01009ab <stab_binsearch>

	if (lfun <= rfun) {
f0100b69:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100b6c:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0100b6f:	7f 2e                	jg     f0100b9f <debuginfo_eip+0x117>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b71:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100b74:	8d 90 f8 20 10 f0    	lea    -0xfefdf08(%eax),%edx
f0100b7a:	8b 80 f8 20 10 f0    	mov    -0xfefdf08(%eax),%eax
f0100b80:	b9 c6 72 10 f0       	mov    $0xf01072c6,%ecx
f0100b85:	81 e9 c9 59 10 f0    	sub    $0xf01059c9,%ecx
f0100b8b:	39 c8                	cmp    %ecx,%eax
f0100b8d:	73 08                	jae    f0100b97 <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b8f:	05 c9 59 10 f0       	add    $0xf01059c9,%eax
f0100b94:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b97:	8b 42 08             	mov    0x8(%edx),%eax
f0100b9a:	89 43 10             	mov    %eax,0x10(%ebx)
f0100b9d:	eb 06                	jmp    f0100ba5 <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b9f:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100ba2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100ba5:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100bac:	00 
f0100bad:	8b 43 08             	mov    0x8(%ebx),%eax
f0100bb0:	89 04 24             	mov    %eax,(%esp)
f0100bb3:	e8 13 09 00 00       	call   f01014cb <strfind>
f0100bb8:	2b 43 08             	sub    0x8(%ebx),%eax
f0100bbb:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100bbe:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100bc1:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100bc4:	05 f8 20 10 f0       	add    $0xf01020f8,%eax
f0100bc9:	eb 06                	jmp    f0100bd1 <debuginfo_eip+0x149>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100bcb:	83 ef 01             	sub    $0x1,%edi
f0100bce:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100bd1:	39 cf                	cmp    %ecx,%edi
f0100bd3:	7c 33                	jl     f0100c08 <debuginfo_eip+0x180>
	       && stabs[lline].n_type != N_SOL
f0100bd5:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0100bd9:	80 fa 84             	cmp    $0x84,%dl
f0100bdc:	74 0b                	je     f0100be9 <debuginfo_eip+0x161>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100bde:	80 fa 64             	cmp    $0x64,%dl
f0100be1:	75 e8                	jne    f0100bcb <debuginfo_eip+0x143>
f0100be3:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100be7:	74 e2                	je     f0100bcb <debuginfo_eip+0x143>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100be9:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100bec:	8b 87 f8 20 10 f0    	mov    -0xfefdf08(%edi),%eax
f0100bf2:	ba c6 72 10 f0       	mov    $0xf01072c6,%edx
f0100bf7:	81 ea c9 59 10 f0    	sub    $0xf01059c9,%edx
f0100bfd:	39 d0                	cmp    %edx,%eax
f0100bff:	73 07                	jae    f0100c08 <debuginfo_eip+0x180>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c01:	05 c9 59 10 f0       	add    $0xf01059c9,%eax
f0100c06:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c08:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100c0b:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c0e:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c13:	39 f1                	cmp    %esi,%ecx
f0100c15:	7d 42                	jge    f0100c59 <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
f0100c17:	8d 51 01             	lea    0x1(%ecx),%edx
f0100c1a:	6b c1 0c             	imul   $0xc,%ecx,%eax
f0100c1d:	05 f8 20 10 f0       	add    $0xf01020f8,%eax
f0100c22:	eb 07                	jmp    f0100c2b <debuginfo_eip+0x1a3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c24:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100c28:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100c2b:	39 f2                	cmp    %esi,%edx
f0100c2d:	74 25                	je     f0100c54 <debuginfo_eip+0x1cc>
f0100c2f:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c32:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0100c36:	74 ec                	je     f0100c24 <debuginfo_eip+0x19c>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c38:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c3d:	eb 1a                	jmp    f0100c59 <debuginfo_eip+0x1d1>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c44:	eb 13                	jmp    f0100c59 <debuginfo_eip+0x1d1>
f0100c46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c4b:	eb 0c                	jmp    f0100c59 <debuginfo_eip+0x1d1>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100c4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c52:	eb 05                	jmp    f0100c59 <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c54:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c59:	83 c4 2c             	add    $0x2c,%esp
f0100c5c:	5b                   	pop    %ebx
f0100c5d:	5e                   	pop    %esi
f0100c5e:	5f                   	pop    %edi
f0100c5f:	5d                   	pop    %ebp
f0100c60:	c3                   	ret    
f0100c61:	66 90                	xchg   %ax,%ax
f0100c63:	66 90                	xchg   %ax,%ax
f0100c65:	66 90                	xchg   %ax,%ax
f0100c67:	66 90                	xchg   %ax,%ax
f0100c69:	66 90                	xchg   %ax,%ax
f0100c6b:	66 90                	xchg   %ax,%ax
f0100c6d:	66 90                	xchg   %ax,%ax
f0100c6f:	90                   	nop

f0100c70 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100c70:	55                   	push   %ebp
f0100c71:	89 e5                	mov    %esp,%ebp
f0100c73:	57                   	push   %edi
f0100c74:	56                   	push   %esi
f0100c75:	53                   	push   %ebx
f0100c76:	83 ec 3c             	sub    $0x3c,%esp
f0100c79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100c7c:	89 d7                	mov    %edx,%edi
f0100c7e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c81:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100c84:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c87:	89 c3                	mov    %eax,%ebx
f0100c89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100c8c:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c8f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100c92:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100c97:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100c9a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100c9d:	39 d9                	cmp    %ebx,%ecx
f0100c9f:	72 05                	jb     f0100ca6 <printnum+0x36>
f0100ca1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0100ca4:	77 69                	ja     f0100d0f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ca6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0100ca9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0100cad:	83 ee 01             	sub    $0x1,%esi
f0100cb0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100cb4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100cb8:	8b 44 24 08          	mov    0x8(%esp),%eax
f0100cbc:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0100cc0:	89 c3                	mov    %eax,%ebx
f0100cc2:	89 d6                	mov    %edx,%esi
f0100cc4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100cc7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100cca:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100cce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100cd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cd5:	89 04 24             	mov    %eax,(%esp)
f0100cd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cdf:	e8 0c 0a 00 00       	call   f01016f0 <__udivdi3>
f0100ce4:	89 d9                	mov    %ebx,%ecx
f0100ce6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100cea:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100cee:	89 04 24             	mov    %eax,(%esp)
f0100cf1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100cf5:	89 fa                	mov    %edi,%edx
f0100cf7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cfa:	e8 71 ff ff ff       	call   f0100c70 <printnum>
f0100cff:	eb 1b                	jmp    f0100d1c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d01:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d05:	8b 45 18             	mov    0x18(%ebp),%eax
f0100d08:	89 04 24             	mov    %eax,(%esp)
f0100d0b:	ff d3                	call   *%ebx
f0100d0d:	eb 03                	jmp    f0100d12 <printnum+0xa2>
f0100d0f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d12:	83 ee 01             	sub    $0x1,%esi
f0100d15:	85 f6                	test   %esi,%esi
f0100d17:	7f e8                	jg     f0100d01 <printnum+0x91>
f0100d19:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d1c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d20:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100d24:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d27:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d2a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d2e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d32:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d35:	89 04 24             	mov    %eax,(%esp)
f0100d38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d3f:	e8 dc 0a 00 00       	call   f0101820 <__umoddi3>
f0100d44:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d48:	0f be 80 b9 1e 10 f0 	movsbl -0xfefe147(%eax),%eax
f0100d4f:	89 04 24             	mov    %eax,(%esp)
f0100d52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d55:	ff d0                	call   *%eax
}
f0100d57:	83 c4 3c             	add    $0x3c,%esp
f0100d5a:	5b                   	pop    %ebx
f0100d5b:	5e                   	pop    %esi
f0100d5c:	5f                   	pop    %edi
f0100d5d:	5d                   	pop    %ebp
f0100d5e:	c3                   	ret    

f0100d5f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d5f:	55                   	push   %ebp
f0100d60:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d62:	83 fa 01             	cmp    $0x1,%edx
f0100d65:	7e 0e                	jle    f0100d75 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d67:	8b 10                	mov    (%eax),%edx
f0100d69:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d6c:	89 08                	mov    %ecx,(%eax)
f0100d6e:	8b 02                	mov    (%edx),%eax
f0100d70:	8b 52 04             	mov    0x4(%edx),%edx
f0100d73:	eb 22                	jmp    f0100d97 <getuint+0x38>
	else if (lflag)
f0100d75:	85 d2                	test   %edx,%edx
f0100d77:	74 10                	je     f0100d89 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d79:	8b 10                	mov    (%eax),%edx
f0100d7b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d7e:	89 08                	mov    %ecx,(%eax)
f0100d80:	8b 02                	mov    (%edx),%eax
f0100d82:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d87:	eb 0e                	jmp    f0100d97 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100d89:	8b 10                	mov    (%eax),%edx
f0100d8b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d8e:	89 08                	mov    %ecx,(%eax)
f0100d90:	8b 02                	mov    (%edx),%eax
f0100d92:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100d97:	5d                   	pop    %ebp
f0100d98:	c3                   	ret    

f0100d99 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d99:	55                   	push   %ebp
f0100d9a:	89 e5                	mov    %esp,%ebp
f0100d9c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d9f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100da3:	8b 10                	mov    (%eax),%edx
f0100da5:	3b 50 04             	cmp    0x4(%eax),%edx
f0100da8:	73 0a                	jae    f0100db4 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100daa:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100dad:	89 08                	mov    %ecx,(%eax)
f0100daf:	8b 45 08             	mov    0x8(%ebp),%eax
f0100db2:	88 02                	mov    %al,(%edx)
}
f0100db4:	5d                   	pop    %ebp
f0100db5:	c3                   	ret    

f0100db6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100db6:	55                   	push   %ebp
f0100db7:	89 e5                	mov    %esp,%ebp
f0100db9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100dbc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100dbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100dc3:	8b 45 10             	mov    0x10(%ebp),%eax
f0100dc6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100dca:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100dcd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dd1:	8b 45 08             	mov    0x8(%ebp),%eax
f0100dd4:	89 04 24             	mov    %eax,(%esp)
f0100dd7:	e8 02 00 00 00       	call   f0100dde <vprintfmt>
	va_end(ap);
}
f0100ddc:	c9                   	leave  
f0100ddd:	c3                   	ret    

f0100dde <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100dde:	55                   	push   %ebp
f0100ddf:	89 e5                	mov    %esp,%ebp
f0100de1:	57                   	push   %edi
f0100de2:	56                   	push   %esi
f0100de3:	53                   	push   %ebx
f0100de4:	83 ec 3c             	sub    $0x3c,%esp
f0100de7:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100dea:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0100ded:	eb 1e                	jmp    f0100e0d <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0'){
f0100def:	85 c0                	test   %eax,%eax
f0100df1:	75 0e                	jne    f0100e01 <vprintfmt+0x23>
				csa = 0x0700; //change color back
f0100df3:	66 c7 05 44 29 11 f0 	movw   $0x700,0xf0112944
f0100dfa:	00 07 
f0100dfc:	e9 f5 03 00 00       	jmp    f01011f6 <vprintfmt+0x418>
				return;
			}
			putch(ch, putdat);
f0100e01:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e05:	89 04 24             	mov    %eax,(%esp)
f0100e08:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e0b:	89 f3                	mov    %esi,%ebx
f0100e0d:	8d 73 01             	lea    0x1(%ebx),%esi
f0100e10:	0f b6 03             	movzbl (%ebx),%eax
f0100e13:	83 f8 25             	cmp    $0x25,%eax
f0100e16:	75 d7                	jne    f0100def <vprintfmt+0x11>
f0100e18:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0100e1c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100e23:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0100e2a:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0100e31:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e36:	eb 1d                	jmp    f0100e55 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e38:	89 de                	mov    %ebx,%esi
      csa = num;
      break;

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e3a:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0100e3e:	eb 15                	jmp    f0100e55 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e40:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e42:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0100e46:	eb 0d                	jmp    f0100e55 <vprintfmt+0x77>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100e48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e4b:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100e4e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e55:	8d 5e 01             	lea    0x1(%esi),%ebx
f0100e58:	0f b6 06             	movzbl (%esi),%eax
f0100e5b:	0f b6 c8             	movzbl %al,%ecx
f0100e5e:	83 e8 23             	sub    $0x23,%eax
f0100e61:	3c 55                	cmp    $0x55,%al
f0100e63:	0f 87 6d 03 00 00    	ja     f01011d6 <vprintfmt+0x3f8>
f0100e69:	0f b6 c0             	movzbl %al,%eax
f0100e6c:	ff 24 85 60 1f 10 f0 	jmp    *-0xfefe0a0(,%eax,4)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100e73:	83 fa 01             	cmp    $0x1,%edx
f0100e76:	7e 0d                	jle    f0100e85 <vprintfmt+0xa7>
		return va_arg(*ap, long long);
f0100e78:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e7b:	8d 50 08             	lea    0x8(%eax),%edx
f0100e7e:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e81:	8b 00                	mov    (%eax),%eax
f0100e83:	eb 1c                	jmp    f0100ea1 <vprintfmt+0xc3>
	else if (lflag)
f0100e85:	85 d2                	test   %edx,%edx
f0100e87:	74 0d                	je     f0100e96 <vprintfmt+0xb8>
		return va_arg(*ap, long);
f0100e89:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e8c:	8d 50 04             	lea    0x4(%eax),%edx
f0100e8f:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e92:	8b 00                	mov    (%eax),%eax
f0100e94:	eb 0b                	jmp    f0100ea1 <vprintfmt+0xc3>
	else
		return va_arg(*ap, int);
f0100e96:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e99:	8d 50 04             	lea    0x4(%eax),%edx
f0100e9c:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e9f:	8b 00                	mov    (%eax),%eax
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		case 'm': //change color
      num = getint(&ap, lflag);
      csa = num;
f0100ea1:	66 a3 44 29 11 f0    	mov    %ax,0xf0112944
      break;
f0100ea7:	e9 61 ff ff ff       	jmp    f0100e0d <vprintfmt+0x2f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eac:	89 de                	mov    %ebx,%esi
f0100eae:	b8 00 00 00 00       	mov    $0x0,%eax
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100eb3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100eb6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100eba:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
f0100ebd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0100ec0:	83 fb 09             	cmp    $0x9,%ebx
f0100ec3:	77 3c                	ja     f0100f01 <vprintfmt+0x123>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100ec5:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100ec8:	eb e9                	jmp    f0100eb3 <vprintfmt+0xd5>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100eca:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ecd:	8d 48 04             	lea    0x4(%eax),%ecx
f0100ed0:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100ed3:	8b 00                	mov    (%eax),%eax
f0100ed5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ed8:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100eda:	eb 28                	jmp    f0100f04 <vprintfmt+0x126>
f0100edc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100edf:	85 c9                	test   %ecx,%ecx
f0100ee1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ee6:	0f 49 c1             	cmovns %ecx,%eax
f0100ee9:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eec:	89 de                	mov    %ebx,%esi
f0100eee:	e9 62 ff ff ff       	jmp    f0100e55 <vprintfmt+0x77>
f0100ef3:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100ef5:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0100efc:	e9 54 ff ff ff       	jmp    f0100e55 <vprintfmt+0x77>
f0100f01:	89 45 d4             	mov    %eax,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f0100f04:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100f08:	0f 89 47 ff ff ff    	jns    f0100e55 <vprintfmt+0x77>
f0100f0e:	e9 35 ff ff ff       	jmp    f0100e48 <vprintfmt+0x6a>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100f13:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f16:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100f18:	e9 38 ff ff ff       	jmp    f0100e55 <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100f1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f20:	8d 50 04             	lea    0x4(%eax),%edx
f0100f23:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f26:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100f2a:	8b 00                	mov    (%eax),%eax
f0100f2c:	89 04 24             	mov    %eax,(%esp)
f0100f2f:	ff 55 08             	call   *0x8(%ebp)
			break;
f0100f32:	e9 d6 fe ff ff       	jmp    f0100e0d <vprintfmt+0x2f>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f37:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f3a:	8d 50 04             	lea    0x4(%eax),%edx
f0100f3d:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f40:	8b 00                	mov    (%eax),%eax
f0100f42:	99                   	cltd   
f0100f43:	31 d0                	xor    %edx,%eax
f0100f45:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f47:	83 f8 07             	cmp    $0x7,%eax
f0100f4a:	7f 0b                	jg     f0100f57 <vprintfmt+0x179>
f0100f4c:	8b 14 85 c0 20 10 f0 	mov    -0xfefdf40(,%eax,4),%edx
f0100f53:	85 d2                	test   %edx,%edx
f0100f55:	75 20                	jne    f0100f77 <vprintfmt+0x199>
				printfmt(putch, putdat, "error %d", err);
f0100f57:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f5b:	c7 44 24 08 d1 1e 10 	movl   $0xf0101ed1,0x8(%esp)
f0100f62:	f0 
f0100f63:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100f67:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f6a:	89 04 24             	mov    %eax,(%esp)
f0100f6d:	e8 44 fe ff ff       	call   f0100db6 <printfmt>
f0100f72:	e9 96 fe ff ff       	jmp    f0100e0d <vprintfmt+0x2f>
			else
				printfmt(putch, putdat, "%s", p);
f0100f77:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100f7b:	c7 44 24 08 e2 20 10 	movl   $0xf01020e2,0x8(%esp)
f0100f82:	f0 
f0100f83:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100f87:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f8a:	89 04 24             	mov    %eax,(%esp)
f0100f8d:	e8 24 fe ff ff       	call   f0100db6 <printfmt>
f0100f92:	e9 76 fe ff ff       	jmp    f0100e0d <vprintfmt+0x2f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f97:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100f9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f9d:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100fa0:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fa3:	8d 50 04             	lea    0x4(%eax),%edx
f0100fa6:	89 55 14             	mov    %edx,0x14(%ebp)
f0100fa9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0100fab:	85 f6                	test   %esi,%esi
f0100fad:	b8 ca 1e 10 f0       	mov    $0xf0101eca,%eax
f0100fb2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0100fb5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0100fb9:	0f 84 97 00 00 00    	je     f0101056 <vprintfmt+0x278>
f0100fbf:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100fc3:	0f 8e 9b 00 00 00    	jle    f0101064 <vprintfmt+0x286>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fc9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100fcd:	89 34 24             	mov    %esi,(%esp)
f0100fd0:	e8 a3 03 00 00       	call   f0101378 <strnlen>
f0100fd5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100fd8:	29 c1                	sub    %eax,%ecx
f0100fda:	89 4d d0             	mov    %ecx,-0x30(%ebp)
					putch(padc, putdat);
f0100fdd:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0100fe1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100fe4:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0100fe7:	8b 75 08             	mov    0x8(%ebp),%esi
f0100fea:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0100fed:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fef:	eb 0f                	jmp    f0101000 <vprintfmt+0x222>
					putch(padc, putdat);
f0100ff1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100ff5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ff8:	89 04 24             	mov    %eax,(%esp)
f0100ffb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ffd:	83 eb 01             	sub    $0x1,%ebx
f0101000:	85 db                	test   %ebx,%ebx
f0101002:	7f ed                	jg     f0100ff1 <vprintfmt+0x213>
f0101004:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0101007:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010100a:	85 c9                	test   %ecx,%ecx
f010100c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101011:	0f 49 c1             	cmovns %ecx,%eax
f0101014:	29 c1                	sub    %eax,%ecx
f0101016:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101019:	89 cf                	mov    %ecx,%edi
f010101b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010101e:	eb 50                	jmp    f0101070 <vprintfmt+0x292>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101020:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101024:	74 1e                	je     f0101044 <vprintfmt+0x266>
f0101026:	0f be d2             	movsbl %dl,%edx
f0101029:	83 ea 20             	sub    $0x20,%edx
f010102c:	83 fa 5e             	cmp    $0x5e,%edx
f010102f:	76 13                	jbe    f0101044 <vprintfmt+0x266>
					putch('?', putdat);
f0101031:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101034:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101038:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010103f:	ff 55 08             	call   *0x8(%ebp)
f0101042:	eb 0d                	jmp    f0101051 <vprintfmt+0x273>
				else
					putch(ch, putdat);
f0101044:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101047:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010104b:	89 04 24             	mov    %eax,(%esp)
f010104e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101051:	83 ef 01             	sub    $0x1,%edi
f0101054:	eb 1a                	jmp    f0101070 <vprintfmt+0x292>
f0101056:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101059:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010105c:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010105f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101062:	eb 0c                	jmp    f0101070 <vprintfmt+0x292>
f0101064:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101067:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010106a:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010106d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101070:	83 c6 01             	add    $0x1,%esi
f0101073:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f0101077:	0f be c2             	movsbl %dl,%eax
f010107a:	85 c0                	test   %eax,%eax
f010107c:	74 27                	je     f01010a5 <vprintfmt+0x2c7>
f010107e:	85 db                	test   %ebx,%ebx
f0101080:	78 9e                	js     f0101020 <vprintfmt+0x242>
f0101082:	83 eb 01             	sub    $0x1,%ebx
f0101085:	79 99                	jns    f0101020 <vprintfmt+0x242>
f0101087:	89 f8                	mov    %edi,%eax
f0101089:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010108c:	8b 75 08             	mov    0x8(%ebp),%esi
f010108f:	89 c3                	mov    %eax,%ebx
f0101091:	eb 1a                	jmp    f01010ad <vprintfmt+0x2cf>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101093:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101097:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010109e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01010a0:	83 eb 01             	sub    $0x1,%ebx
f01010a3:	eb 08                	jmp    f01010ad <vprintfmt+0x2cf>
f01010a5:	89 fb                	mov    %edi,%ebx
f01010a7:	8b 75 08             	mov    0x8(%ebp),%esi
f01010aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01010ad:	85 db                	test   %ebx,%ebx
f01010af:	7f e2                	jg     f0101093 <vprintfmt+0x2b5>
f01010b1:	89 75 08             	mov    %esi,0x8(%ebp)
f01010b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01010b7:	e9 51 fd ff ff       	jmp    f0100e0d <vprintfmt+0x2f>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01010bc:	83 fa 01             	cmp    $0x1,%edx
f01010bf:	7e 16                	jle    f01010d7 <vprintfmt+0x2f9>
		return va_arg(*ap, long long);
f01010c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c4:	8d 50 08             	lea    0x8(%eax),%edx
f01010c7:	89 55 14             	mov    %edx,0x14(%ebp)
f01010ca:	8b 50 04             	mov    0x4(%eax),%edx
f01010cd:	8b 00                	mov    (%eax),%eax
f01010cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010d2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01010d5:	eb 32                	jmp    f0101109 <vprintfmt+0x32b>
	else if (lflag)
f01010d7:	85 d2                	test   %edx,%edx
f01010d9:	74 18                	je     f01010f3 <vprintfmt+0x315>
		return va_arg(*ap, long);
f01010db:	8b 45 14             	mov    0x14(%ebp),%eax
f01010de:	8d 50 04             	lea    0x4(%eax),%edx
f01010e1:	89 55 14             	mov    %edx,0x14(%ebp)
f01010e4:	8b 30                	mov    (%eax),%esi
f01010e6:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01010e9:	89 f0                	mov    %esi,%eax
f01010eb:	c1 f8 1f             	sar    $0x1f,%eax
f01010ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010f1:	eb 16                	jmp    f0101109 <vprintfmt+0x32b>
	else
		return va_arg(*ap, int);
f01010f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f6:	8d 50 04             	lea    0x4(%eax),%edx
f01010f9:	89 55 14             	mov    %edx,0x14(%ebp)
f01010fc:	8b 30                	mov    (%eax),%esi
f01010fe:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0101101:	89 f0                	mov    %esi,%eax
f0101103:	c1 f8 1f             	sar    $0x1f,%eax
f0101106:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101109:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010110c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010110f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101114:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101118:	0f 89 80 00 00 00    	jns    f010119e <vprintfmt+0x3c0>
				putch('-', putdat);
f010111e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101122:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101129:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010112c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010112f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101132:	f7 d8                	neg    %eax
f0101134:	83 d2 00             	adc    $0x0,%edx
f0101137:	f7 da                	neg    %edx
			}
			base = 10;
f0101139:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010113e:	eb 5e                	jmp    f010119e <vprintfmt+0x3c0>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101140:	8d 45 14             	lea    0x14(%ebp),%eax
f0101143:	e8 17 fc ff ff       	call   f0100d5f <getuint>
			base = 10;
f0101148:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010114d:	eb 4f                	jmp    f010119e <vprintfmt+0x3c0>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f010114f:	8d 45 14             	lea    0x14(%ebp),%eax
f0101152:	e8 08 fc ff ff       	call   f0100d5f <getuint>
      base = 8;
f0101157:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
f010115c:	eb 40                	jmp    f010119e <vprintfmt+0x3c0>

		// pointer
		case 'p':
			putch('0', putdat);
f010115e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101162:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101169:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010116c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101170:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0101177:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010117a:	8b 45 14             	mov    0x14(%ebp),%eax
f010117d:	8d 50 04             	lea    0x4(%eax),%edx
f0101180:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101183:	8b 00                	mov    (%eax),%eax
f0101185:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010118a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010118f:	eb 0d                	jmp    f010119e <vprintfmt+0x3c0>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101191:	8d 45 14             	lea    0x14(%ebp),%eax
f0101194:	e8 c6 fb ff ff       	call   f0100d5f <getuint>
			base = 16;
f0101199:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010119e:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f01011a2:	89 74 24 10          	mov    %esi,0x10(%esp)
f01011a6:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01011a9:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01011ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01011b1:	89 04 24             	mov    %eax,(%esp)
f01011b4:	89 54 24 04          	mov    %edx,0x4(%esp)
f01011b8:	89 fa                	mov    %edi,%edx
f01011ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01011bd:	e8 ae fa ff ff       	call   f0100c70 <printnum>
			break;
f01011c2:	e9 46 fc ff ff       	jmp    f0100e0d <vprintfmt+0x2f>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01011c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01011cb:	89 0c 24             	mov    %ecx,(%esp)
f01011ce:	ff 55 08             	call   *0x8(%ebp)
			break;
f01011d1:	e9 37 fc ff ff       	jmp    f0100e0d <vprintfmt+0x2f>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01011d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01011da:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01011e1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01011e4:	89 f3                	mov    %esi,%ebx
f01011e6:	eb 03                	jmp    f01011eb <vprintfmt+0x40d>
f01011e8:	83 eb 01             	sub    $0x1,%ebx
f01011eb:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f01011ef:	75 f7                	jne    f01011e8 <vprintfmt+0x40a>
f01011f1:	e9 17 fc ff ff       	jmp    f0100e0d <vprintfmt+0x2f>
				/* do nothing */;
			break;
		}
	}
}
f01011f6:	83 c4 3c             	add    $0x3c,%esp
f01011f9:	5b                   	pop    %ebx
f01011fa:	5e                   	pop    %esi
f01011fb:	5f                   	pop    %edi
f01011fc:	5d                   	pop    %ebp
f01011fd:	c3                   	ret    

f01011fe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01011fe:	55                   	push   %ebp
f01011ff:	89 e5                	mov    %esp,%ebp
f0101201:	83 ec 28             	sub    $0x28,%esp
f0101204:	8b 45 08             	mov    0x8(%ebp),%eax
f0101207:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010120a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010120d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101211:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101214:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010121b:	85 c0                	test   %eax,%eax
f010121d:	74 30                	je     f010124f <vsnprintf+0x51>
f010121f:	85 d2                	test   %edx,%edx
f0101221:	7e 2c                	jle    f010124f <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101223:	8b 45 14             	mov    0x14(%ebp),%eax
f0101226:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010122a:	8b 45 10             	mov    0x10(%ebp),%eax
f010122d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101231:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101234:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101238:	c7 04 24 99 0d 10 f0 	movl   $0xf0100d99,(%esp)
f010123f:	e8 9a fb ff ff       	call   f0100dde <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101244:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101247:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010124a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010124d:	eb 05                	jmp    f0101254 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010124f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101254:	c9                   	leave  
f0101255:	c3                   	ret    

f0101256 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101256:	55                   	push   %ebp
f0101257:	89 e5                	mov    %esp,%ebp
f0101259:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010125c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010125f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101263:	8b 45 10             	mov    0x10(%ebp),%eax
f0101266:	89 44 24 08          	mov    %eax,0x8(%esp)
f010126a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010126d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101271:	8b 45 08             	mov    0x8(%ebp),%eax
f0101274:	89 04 24             	mov    %eax,(%esp)
f0101277:	e8 82 ff ff ff       	call   f01011fe <vsnprintf>
	va_end(ap);

	return rc;
}
f010127c:	c9                   	leave  
f010127d:	c3                   	ret    
f010127e:	66 90                	xchg   %ax,%ax

f0101280 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101280:	55                   	push   %ebp
f0101281:	89 e5                	mov    %esp,%ebp
f0101283:	57                   	push   %edi
f0101284:	56                   	push   %esi
f0101285:	53                   	push   %ebx
f0101286:	83 ec 1c             	sub    $0x1c,%esp
f0101289:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010128c:	85 c0                	test   %eax,%eax
f010128e:	74 18                	je     f01012a8 <readline+0x28>
		cprintf("%m%s", 0x0400 ,  prompt);
f0101290:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101294:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f010129b:	00 
f010129c:	c7 04 24 e0 20 10 f0 	movl   $0xf01020e0,(%esp)
f01012a3:	e8 e9 f6 ff ff       	call   f0100991 <cprintf>

	i = 0;
	echoing = iscons(0);
f01012a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012af:	e8 d7 f3 ff ff       	call   f010068b <iscons>
f01012b4:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%m%s", 0x0400 ,  prompt);

	i = 0;
f01012b6:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01012bb:	e8 ba f3 ff ff       	call   f010067a <getchar>
f01012c0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01012c2:	85 c0                	test   %eax,%eax
f01012c4:	79 17                	jns    f01012dd <readline+0x5d>
			cprintf("read error: %e\n", c);
f01012c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012ca:	c7 04 24 e5 20 10 f0 	movl   $0xf01020e5,(%esp)
f01012d1:	e8 bb f6 ff ff       	call   f0100991 <cprintf>
			return NULL;
f01012d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01012db:	eb 70                	jmp    f010134d <readline+0xcd>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01012dd:	83 f8 7f             	cmp    $0x7f,%eax
f01012e0:	74 05                	je     f01012e7 <readline+0x67>
f01012e2:	83 f8 08             	cmp    $0x8,%eax
f01012e5:	75 1c                	jne    f0101303 <readline+0x83>
f01012e7:	85 f6                	test   %esi,%esi
f01012e9:	7e 18                	jle    f0101303 <readline+0x83>
			if (echoing)
f01012eb:	85 ff                	test   %edi,%edi
f01012ed:	8d 76 00             	lea    0x0(%esi),%esi
f01012f0:	74 0c                	je     f01012fe <readline+0x7e>
				cputchar('\b');
f01012f2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01012f9:	e8 6c f3 ff ff       	call   f010066a <cputchar>
			i--;
f01012fe:	83 ee 01             	sub    $0x1,%esi
f0101301:	eb b8                	jmp    f01012bb <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101303:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101309:	7f 1c                	jg     f0101327 <readline+0xa7>
f010130b:	83 fb 1f             	cmp    $0x1f,%ebx
f010130e:	7e 17                	jle    f0101327 <readline+0xa7>
			if (echoing)
f0101310:	85 ff                	test   %edi,%edi
f0101312:	74 08                	je     f010131c <readline+0x9c>
				cputchar(c);
f0101314:	89 1c 24             	mov    %ebx,(%esp)
f0101317:	e8 4e f3 ff ff       	call   f010066a <cputchar>
			buf[i++] = c;
f010131c:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101322:	8d 76 01             	lea    0x1(%esi),%esi
f0101325:	eb 94                	jmp    f01012bb <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
f0101327:	83 fb 0d             	cmp    $0xd,%ebx
f010132a:	74 05                	je     f0101331 <readline+0xb1>
f010132c:	83 fb 0a             	cmp    $0xa,%ebx
f010132f:	75 8a                	jne    f01012bb <readline+0x3b>
			if (echoing)
f0101331:	85 ff                	test   %edi,%edi
f0101333:	74 0c                	je     f0101341 <readline+0xc1>
				cputchar('\n');
f0101335:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010133c:	e8 29 f3 ff ff       	call   f010066a <cputchar>
			buf[i] = 0;
f0101341:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f0101348:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f010134d:	83 c4 1c             	add    $0x1c,%esp
f0101350:	5b                   	pop    %ebx
f0101351:	5e                   	pop    %esi
f0101352:	5f                   	pop    %edi
f0101353:	5d                   	pop    %ebp
f0101354:	c3                   	ret    
f0101355:	66 90                	xchg   %ax,%ax
f0101357:	66 90                	xchg   %ax,%ax
f0101359:	66 90                	xchg   %ax,%ax
f010135b:	66 90                	xchg   %ax,%ax
f010135d:	66 90                	xchg   %ax,%ax
f010135f:	90                   	nop

f0101360 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101360:	55                   	push   %ebp
f0101361:	89 e5                	mov    %esp,%ebp
f0101363:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101366:	b8 00 00 00 00       	mov    $0x0,%eax
f010136b:	eb 03                	jmp    f0101370 <strlen+0x10>
		n++;
f010136d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101370:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101374:	75 f7                	jne    f010136d <strlen+0xd>
		n++;
	return n;
}
f0101376:	5d                   	pop    %ebp
f0101377:	c3                   	ret    

f0101378 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101378:	55                   	push   %ebp
f0101379:	89 e5                	mov    %esp,%ebp
f010137b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010137e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101381:	b8 00 00 00 00       	mov    $0x0,%eax
f0101386:	eb 03                	jmp    f010138b <strnlen+0x13>
		n++;
f0101388:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010138b:	39 d0                	cmp    %edx,%eax
f010138d:	74 06                	je     f0101395 <strnlen+0x1d>
f010138f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101393:	75 f3                	jne    f0101388 <strnlen+0x10>
		n++;
	return n;
}
f0101395:	5d                   	pop    %ebp
f0101396:	c3                   	ret    

f0101397 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101397:	55                   	push   %ebp
f0101398:	89 e5                	mov    %esp,%ebp
f010139a:	53                   	push   %ebx
f010139b:	8b 45 08             	mov    0x8(%ebp),%eax
f010139e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01013a1:	89 c2                	mov    %eax,%edx
f01013a3:	83 c2 01             	add    $0x1,%edx
f01013a6:	83 c1 01             	add    $0x1,%ecx
f01013a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01013ad:	88 5a ff             	mov    %bl,-0x1(%edx)
f01013b0:	84 db                	test   %bl,%bl
f01013b2:	75 ef                	jne    f01013a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01013b4:	5b                   	pop    %ebx
f01013b5:	5d                   	pop    %ebp
f01013b6:	c3                   	ret    

f01013b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01013b7:	55                   	push   %ebp
f01013b8:	89 e5                	mov    %esp,%ebp
f01013ba:	53                   	push   %ebx
f01013bb:	83 ec 08             	sub    $0x8,%esp
f01013be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01013c1:	89 1c 24             	mov    %ebx,(%esp)
f01013c4:	e8 97 ff ff ff       	call   f0101360 <strlen>
	strcpy(dst + len, src);
f01013c9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013cc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01013d0:	01 d8                	add    %ebx,%eax
f01013d2:	89 04 24             	mov    %eax,(%esp)
f01013d5:	e8 bd ff ff ff       	call   f0101397 <strcpy>
	return dst;
}
f01013da:	89 d8                	mov    %ebx,%eax
f01013dc:	83 c4 08             	add    $0x8,%esp
f01013df:	5b                   	pop    %ebx
f01013e0:	5d                   	pop    %ebp
f01013e1:	c3                   	ret    

f01013e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01013e2:	55                   	push   %ebp
f01013e3:	89 e5                	mov    %esp,%ebp
f01013e5:	56                   	push   %esi
f01013e6:	53                   	push   %ebx
f01013e7:	8b 75 08             	mov    0x8(%ebp),%esi
f01013ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013ed:	89 f3                	mov    %esi,%ebx
f01013ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013f2:	89 f2                	mov    %esi,%edx
f01013f4:	eb 0f                	jmp    f0101405 <strncpy+0x23>
		*dst++ = *src;
f01013f6:	83 c2 01             	add    $0x1,%edx
f01013f9:	0f b6 01             	movzbl (%ecx),%eax
f01013fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01013ff:	80 39 01             	cmpb   $0x1,(%ecx)
f0101402:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101405:	39 da                	cmp    %ebx,%edx
f0101407:	75 ed                	jne    f01013f6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101409:	89 f0                	mov    %esi,%eax
f010140b:	5b                   	pop    %ebx
f010140c:	5e                   	pop    %esi
f010140d:	5d                   	pop    %ebp
f010140e:	c3                   	ret    

f010140f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010140f:	55                   	push   %ebp
f0101410:	89 e5                	mov    %esp,%ebp
f0101412:	56                   	push   %esi
f0101413:	53                   	push   %ebx
f0101414:	8b 75 08             	mov    0x8(%ebp),%esi
f0101417:	8b 55 0c             	mov    0xc(%ebp),%edx
f010141a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010141d:	89 f0                	mov    %esi,%eax
f010141f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101423:	85 c9                	test   %ecx,%ecx
f0101425:	75 0b                	jne    f0101432 <strlcpy+0x23>
f0101427:	eb 1d                	jmp    f0101446 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101429:	83 c0 01             	add    $0x1,%eax
f010142c:	83 c2 01             	add    $0x1,%edx
f010142f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101432:	39 d8                	cmp    %ebx,%eax
f0101434:	74 0b                	je     f0101441 <strlcpy+0x32>
f0101436:	0f b6 0a             	movzbl (%edx),%ecx
f0101439:	84 c9                	test   %cl,%cl
f010143b:	75 ec                	jne    f0101429 <strlcpy+0x1a>
f010143d:	89 c2                	mov    %eax,%edx
f010143f:	eb 02                	jmp    f0101443 <strlcpy+0x34>
f0101441:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0101443:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0101446:	29 f0                	sub    %esi,%eax
}
f0101448:	5b                   	pop    %ebx
f0101449:	5e                   	pop    %esi
f010144a:	5d                   	pop    %ebp
f010144b:	c3                   	ret    

f010144c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010144c:	55                   	push   %ebp
f010144d:	89 e5                	mov    %esp,%ebp
f010144f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101452:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101455:	eb 06                	jmp    f010145d <strcmp+0x11>
		p++, q++;
f0101457:	83 c1 01             	add    $0x1,%ecx
f010145a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010145d:	0f b6 01             	movzbl (%ecx),%eax
f0101460:	84 c0                	test   %al,%al
f0101462:	74 04                	je     f0101468 <strcmp+0x1c>
f0101464:	3a 02                	cmp    (%edx),%al
f0101466:	74 ef                	je     f0101457 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101468:	0f b6 c0             	movzbl %al,%eax
f010146b:	0f b6 12             	movzbl (%edx),%edx
f010146e:	29 d0                	sub    %edx,%eax
}
f0101470:	5d                   	pop    %ebp
f0101471:	c3                   	ret    

f0101472 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101472:	55                   	push   %ebp
f0101473:	89 e5                	mov    %esp,%ebp
f0101475:	53                   	push   %ebx
f0101476:	8b 45 08             	mov    0x8(%ebp),%eax
f0101479:	8b 55 0c             	mov    0xc(%ebp),%edx
f010147c:	89 c3                	mov    %eax,%ebx
f010147e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101481:	eb 06                	jmp    f0101489 <strncmp+0x17>
		n--, p++, q++;
f0101483:	83 c0 01             	add    $0x1,%eax
f0101486:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101489:	39 d8                	cmp    %ebx,%eax
f010148b:	74 15                	je     f01014a2 <strncmp+0x30>
f010148d:	0f b6 08             	movzbl (%eax),%ecx
f0101490:	84 c9                	test   %cl,%cl
f0101492:	74 04                	je     f0101498 <strncmp+0x26>
f0101494:	3a 0a                	cmp    (%edx),%cl
f0101496:	74 eb                	je     f0101483 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101498:	0f b6 00             	movzbl (%eax),%eax
f010149b:	0f b6 12             	movzbl (%edx),%edx
f010149e:	29 d0                	sub    %edx,%eax
f01014a0:	eb 05                	jmp    f01014a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01014a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01014a7:	5b                   	pop    %ebx
f01014a8:	5d                   	pop    %ebp
f01014a9:	c3                   	ret    

f01014aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01014aa:	55                   	push   %ebp
f01014ab:	89 e5                	mov    %esp,%ebp
f01014ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01014b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01014b4:	eb 07                	jmp    f01014bd <strchr+0x13>
		if (*s == c)
f01014b6:	38 ca                	cmp    %cl,%dl
f01014b8:	74 0f                	je     f01014c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01014ba:	83 c0 01             	add    $0x1,%eax
f01014bd:	0f b6 10             	movzbl (%eax),%edx
f01014c0:	84 d2                	test   %dl,%dl
f01014c2:	75 f2                	jne    f01014b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01014c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014c9:	5d                   	pop    %ebp
f01014ca:	c3                   	ret    

f01014cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01014cb:	55                   	push   %ebp
f01014cc:	89 e5                	mov    %esp,%ebp
f01014ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01014d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01014d5:	eb 07                	jmp    f01014de <strfind+0x13>
		if (*s == c)
f01014d7:	38 ca                	cmp    %cl,%dl
f01014d9:	74 0a                	je     f01014e5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01014db:	83 c0 01             	add    $0x1,%eax
f01014de:	0f b6 10             	movzbl (%eax),%edx
f01014e1:	84 d2                	test   %dl,%dl
f01014e3:	75 f2                	jne    f01014d7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f01014e5:	5d                   	pop    %ebp
f01014e6:	c3                   	ret    

f01014e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01014e7:	55                   	push   %ebp
f01014e8:	89 e5                	mov    %esp,%ebp
f01014ea:	57                   	push   %edi
f01014eb:	56                   	push   %esi
f01014ec:	53                   	push   %ebx
f01014ed:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01014f3:	85 c9                	test   %ecx,%ecx
f01014f5:	74 36                	je     f010152d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01014f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01014fd:	75 28                	jne    f0101527 <memset+0x40>
f01014ff:	f6 c1 03             	test   $0x3,%cl
f0101502:	75 23                	jne    f0101527 <memset+0x40>
		c &= 0xFF;
f0101504:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101508:	89 d3                	mov    %edx,%ebx
f010150a:	c1 e3 08             	shl    $0x8,%ebx
f010150d:	89 d6                	mov    %edx,%esi
f010150f:	c1 e6 18             	shl    $0x18,%esi
f0101512:	89 d0                	mov    %edx,%eax
f0101514:	c1 e0 10             	shl    $0x10,%eax
f0101517:	09 f0                	or     %esi,%eax
f0101519:	09 c2                	or     %eax,%edx
f010151b:	89 d0                	mov    %edx,%eax
f010151d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010151f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101522:	fc                   	cld    
f0101523:	f3 ab                	rep stos %eax,%es:(%edi)
f0101525:	eb 06                	jmp    f010152d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101527:	8b 45 0c             	mov    0xc(%ebp),%eax
f010152a:	fc                   	cld    
f010152b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010152d:	89 f8                	mov    %edi,%eax
f010152f:	5b                   	pop    %ebx
f0101530:	5e                   	pop    %esi
f0101531:	5f                   	pop    %edi
f0101532:	5d                   	pop    %ebp
f0101533:	c3                   	ret    

f0101534 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101534:	55                   	push   %ebp
f0101535:	89 e5                	mov    %esp,%ebp
f0101537:	57                   	push   %edi
f0101538:	56                   	push   %esi
f0101539:	8b 45 08             	mov    0x8(%ebp),%eax
f010153c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010153f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101542:	39 c6                	cmp    %eax,%esi
f0101544:	73 35                	jae    f010157b <memmove+0x47>
f0101546:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101549:	39 d0                	cmp    %edx,%eax
f010154b:	73 2e                	jae    f010157b <memmove+0x47>
		s += n;
		d += n;
f010154d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0101550:	89 d6                	mov    %edx,%esi
f0101552:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101554:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010155a:	75 13                	jne    f010156f <memmove+0x3b>
f010155c:	f6 c1 03             	test   $0x3,%cl
f010155f:	75 0e                	jne    f010156f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101561:	83 ef 04             	sub    $0x4,%edi
f0101564:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101567:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010156a:	fd                   	std    
f010156b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010156d:	eb 09                	jmp    f0101578 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010156f:	83 ef 01             	sub    $0x1,%edi
f0101572:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101575:	fd                   	std    
f0101576:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101578:	fc                   	cld    
f0101579:	eb 1d                	jmp    f0101598 <memmove+0x64>
f010157b:	89 f2                	mov    %esi,%edx
f010157d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010157f:	f6 c2 03             	test   $0x3,%dl
f0101582:	75 0f                	jne    f0101593 <memmove+0x5f>
f0101584:	f6 c1 03             	test   $0x3,%cl
f0101587:	75 0a                	jne    f0101593 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101589:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010158c:	89 c7                	mov    %eax,%edi
f010158e:	fc                   	cld    
f010158f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101591:	eb 05                	jmp    f0101598 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101593:	89 c7                	mov    %eax,%edi
f0101595:	fc                   	cld    
f0101596:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101598:	5e                   	pop    %esi
f0101599:	5f                   	pop    %edi
f010159a:	5d                   	pop    %ebp
f010159b:	c3                   	ret    

f010159c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010159c:	55                   	push   %ebp
f010159d:	89 e5                	mov    %esp,%ebp
f010159f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01015a2:	8b 45 10             	mov    0x10(%ebp),%eax
f01015a5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01015a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01015b3:	89 04 24             	mov    %eax,(%esp)
f01015b6:	e8 79 ff ff ff       	call   f0101534 <memmove>
}
f01015bb:	c9                   	leave  
f01015bc:	c3                   	ret    

f01015bd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01015bd:	55                   	push   %ebp
f01015be:	89 e5                	mov    %esp,%ebp
f01015c0:	56                   	push   %esi
f01015c1:	53                   	push   %ebx
f01015c2:	8b 55 08             	mov    0x8(%ebp),%edx
f01015c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01015c8:	89 d6                	mov    %edx,%esi
f01015ca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015cd:	eb 1a                	jmp    f01015e9 <memcmp+0x2c>
		if (*s1 != *s2)
f01015cf:	0f b6 02             	movzbl (%edx),%eax
f01015d2:	0f b6 19             	movzbl (%ecx),%ebx
f01015d5:	38 d8                	cmp    %bl,%al
f01015d7:	74 0a                	je     f01015e3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01015d9:	0f b6 c0             	movzbl %al,%eax
f01015dc:	0f b6 db             	movzbl %bl,%ebx
f01015df:	29 d8                	sub    %ebx,%eax
f01015e1:	eb 0f                	jmp    f01015f2 <memcmp+0x35>
		s1++, s2++;
f01015e3:	83 c2 01             	add    $0x1,%edx
f01015e6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015e9:	39 f2                	cmp    %esi,%edx
f01015eb:	75 e2                	jne    f01015cf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01015ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015f2:	5b                   	pop    %ebx
f01015f3:	5e                   	pop    %esi
f01015f4:	5d                   	pop    %ebp
f01015f5:	c3                   	ret    

f01015f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01015f6:	55                   	push   %ebp
f01015f7:	89 e5                	mov    %esp,%ebp
f01015f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01015fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01015ff:	89 c2                	mov    %eax,%edx
f0101601:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101604:	eb 07                	jmp    f010160d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101606:	38 08                	cmp    %cl,(%eax)
f0101608:	74 07                	je     f0101611 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010160a:	83 c0 01             	add    $0x1,%eax
f010160d:	39 d0                	cmp    %edx,%eax
f010160f:	72 f5                	jb     f0101606 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101611:	5d                   	pop    %ebp
f0101612:	c3                   	ret    

f0101613 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101613:	55                   	push   %ebp
f0101614:	89 e5                	mov    %esp,%ebp
f0101616:	57                   	push   %edi
f0101617:	56                   	push   %esi
f0101618:	53                   	push   %ebx
f0101619:	8b 55 08             	mov    0x8(%ebp),%edx
f010161c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010161f:	eb 03                	jmp    f0101624 <strtol+0x11>
		s++;
f0101621:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101624:	0f b6 0a             	movzbl (%edx),%ecx
f0101627:	80 f9 09             	cmp    $0x9,%cl
f010162a:	74 f5                	je     f0101621 <strtol+0xe>
f010162c:	80 f9 20             	cmp    $0x20,%cl
f010162f:	74 f0                	je     f0101621 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101631:	80 f9 2b             	cmp    $0x2b,%cl
f0101634:	75 0a                	jne    f0101640 <strtol+0x2d>
		s++;
f0101636:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101639:	bf 00 00 00 00       	mov    $0x0,%edi
f010163e:	eb 11                	jmp    f0101651 <strtol+0x3e>
f0101640:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101645:	80 f9 2d             	cmp    $0x2d,%cl
f0101648:	75 07                	jne    f0101651 <strtol+0x3e>
		s++, neg = 1;
f010164a:	8d 52 01             	lea    0x1(%edx),%edx
f010164d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101651:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0101656:	75 15                	jne    f010166d <strtol+0x5a>
f0101658:	80 3a 30             	cmpb   $0x30,(%edx)
f010165b:	75 10                	jne    f010166d <strtol+0x5a>
f010165d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101661:	75 0a                	jne    f010166d <strtol+0x5a>
		s += 2, base = 16;
f0101663:	83 c2 02             	add    $0x2,%edx
f0101666:	b8 10 00 00 00       	mov    $0x10,%eax
f010166b:	eb 10                	jmp    f010167d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f010166d:	85 c0                	test   %eax,%eax
f010166f:	75 0c                	jne    f010167d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101671:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101673:	80 3a 30             	cmpb   $0x30,(%edx)
f0101676:	75 05                	jne    f010167d <strtol+0x6a>
		s++, base = 8;
f0101678:	83 c2 01             	add    $0x1,%edx
f010167b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f010167d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101682:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101685:	0f b6 0a             	movzbl (%edx),%ecx
f0101688:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010168b:	89 f0                	mov    %esi,%eax
f010168d:	3c 09                	cmp    $0x9,%al
f010168f:	77 08                	ja     f0101699 <strtol+0x86>
			dig = *s - '0';
f0101691:	0f be c9             	movsbl %cl,%ecx
f0101694:	83 e9 30             	sub    $0x30,%ecx
f0101697:	eb 20                	jmp    f01016b9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0101699:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010169c:	89 f0                	mov    %esi,%eax
f010169e:	3c 19                	cmp    $0x19,%al
f01016a0:	77 08                	ja     f01016aa <strtol+0x97>
			dig = *s - 'a' + 10;
f01016a2:	0f be c9             	movsbl %cl,%ecx
f01016a5:	83 e9 57             	sub    $0x57,%ecx
f01016a8:	eb 0f                	jmp    f01016b9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f01016aa:	8d 71 bf             	lea    -0x41(%ecx),%esi
f01016ad:	89 f0                	mov    %esi,%eax
f01016af:	3c 19                	cmp    $0x19,%al
f01016b1:	77 16                	ja     f01016c9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f01016b3:	0f be c9             	movsbl %cl,%ecx
f01016b6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01016b9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01016bc:	7d 0f                	jge    f01016cd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f01016be:	83 c2 01             	add    $0x1,%edx
f01016c1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f01016c5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f01016c7:	eb bc                	jmp    f0101685 <strtol+0x72>
f01016c9:	89 d8                	mov    %ebx,%eax
f01016cb:	eb 02                	jmp    f01016cf <strtol+0xbc>
f01016cd:	89 d8                	mov    %ebx,%eax

	if (endptr)
f01016cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01016d3:	74 05                	je     f01016da <strtol+0xc7>
		*endptr = (char *) s;
f01016d5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016d8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01016da:	f7 d8                	neg    %eax
f01016dc:	85 ff                	test   %edi,%edi
f01016de:	0f 44 c3             	cmove  %ebx,%eax
}
f01016e1:	5b                   	pop    %ebx
f01016e2:	5e                   	pop    %esi
f01016e3:	5f                   	pop    %edi
f01016e4:	5d                   	pop    %ebp
f01016e5:	c3                   	ret    
f01016e6:	66 90                	xchg   %ax,%ax
f01016e8:	66 90                	xchg   %ax,%ax
f01016ea:	66 90                	xchg   %ax,%ax
f01016ec:	66 90                	xchg   %ax,%ax
f01016ee:	66 90                	xchg   %ax,%ax

f01016f0 <__udivdi3>:
f01016f0:	55                   	push   %ebp
f01016f1:	57                   	push   %edi
f01016f2:	56                   	push   %esi
f01016f3:	83 ec 0c             	sub    $0xc,%esp
f01016f6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01016fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01016fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0101702:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0101706:	85 c0                	test   %eax,%eax
f0101708:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010170c:	89 ea                	mov    %ebp,%edx
f010170e:	89 0c 24             	mov    %ecx,(%esp)
f0101711:	75 2d                	jne    f0101740 <__udivdi3+0x50>
f0101713:	39 e9                	cmp    %ebp,%ecx
f0101715:	77 61                	ja     f0101778 <__udivdi3+0x88>
f0101717:	85 c9                	test   %ecx,%ecx
f0101719:	89 ce                	mov    %ecx,%esi
f010171b:	75 0b                	jne    f0101728 <__udivdi3+0x38>
f010171d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101722:	31 d2                	xor    %edx,%edx
f0101724:	f7 f1                	div    %ecx
f0101726:	89 c6                	mov    %eax,%esi
f0101728:	31 d2                	xor    %edx,%edx
f010172a:	89 e8                	mov    %ebp,%eax
f010172c:	f7 f6                	div    %esi
f010172e:	89 c5                	mov    %eax,%ebp
f0101730:	89 f8                	mov    %edi,%eax
f0101732:	f7 f6                	div    %esi
f0101734:	89 ea                	mov    %ebp,%edx
f0101736:	83 c4 0c             	add    $0xc,%esp
f0101739:	5e                   	pop    %esi
f010173a:	5f                   	pop    %edi
f010173b:	5d                   	pop    %ebp
f010173c:	c3                   	ret    
f010173d:	8d 76 00             	lea    0x0(%esi),%esi
f0101740:	39 e8                	cmp    %ebp,%eax
f0101742:	77 24                	ja     f0101768 <__udivdi3+0x78>
f0101744:	0f bd e8             	bsr    %eax,%ebp
f0101747:	83 f5 1f             	xor    $0x1f,%ebp
f010174a:	75 3c                	jne    f0101788 <__udivdi3+0x98>
f010174c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101750:	39 34 24             	cmp    %esi,(%esp)
f0101753:	0f 86 9f 00 00 00    	jbe    f01017f8 <__udivdi3+0x108>
f0101759:	39 d0                	cmp    %edx,%eax
f010175b:	0f 82 97 00 00 00    	jb     f01017f8 <__udivdi3+0x108>
f0101761:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101768:	31 d2                	xor    %edx,%edx
f010176a:	31 c0                	xor    %eax,%eax
f010176c:	83 c4 0c             	add    $0xc,%esp
f010176f:	5e                   	pop    %esi
f0101770:	5f                   	pop    %edi
f0101771:	5d                   	pop    %ebp
f0101772:	c3                   	ret    
f0101773:	90                   	nop
f0101774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101778:	89 f8                	mov    %edi,%eax
f010177a:	f7 f1                	div    %ecx
f010177c:	31 d2                	xor    %edx,%edx
f010177e:	83 c4 0c             	add    $0xc,%esp
f0101781:	5e                   	pop    %esi
f0101782:	5f                   	pop    %edi
f0101783:	5d                   	pop    %ebp
f0101784:	c3                   	ret    
f0101785:	8d 76 00             	lea    0x0(%esi),%esi
f0101788:	89 e9                	mov    %ebp,%ecx
f010178a:	8b 3c 24             	mov    (%esp),%edi
f010178d:	d3 e0                	shl    %cl,%eax
f010178f:	89 c6                	mov    %eax,%esi
f0101791:	b8 20 00 00 00       	mov    $0x20,%eax
f0101796:	29 e8                	sub    %ebp,%eax
f0101798:	89 c1                	mov    %eax,%ecx
f010179a:	d3 ef                	shr    %cl,%edi
f010179c:	89 e9                	mov    %ebp,%ecx
f010179e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01017a2:	8b 3c 24             	mov    (%esp),%edi
f01017a5:	09 74 24 08          	or     %esi,0x8(%esp)
f01017a9:	89 d6                	mov    %edx,%esi
f01017ab:	d3 e7                	shl    %cl,%edi
f01017ad:	89 c1                	mov    %eax,%ecx
f01017af:	89 3c 24             	mov    %edi,(%esp)
f01017b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01017b6:	d3 ee                	shr    %cl,%esi
f01017b8:	89 e9                	mov    %ebp,%ecx
f01017ba:	d3 e2                	shl    %cl,%edx
f01017bc:	89 c1                	mov    %eax,%ecx
f01017be:	d3 ef                	shr    %cl,%edi
f01017c0:	09 d7                	or     %edx,%edi
f01017c2:	89 f2                	mov    %esi,%edx
f01017c4:	89 f8                	mov    %edi,%eax
f01017c6:	f7 74 24 08          	divl   0x8(%esp)
f01017ca:	89 d6                	mov    %edx,%esi
f01017cc:	89 c7                	mov    %eax,%edi
f01017ce:	f7 24 24             	mull   (%esp)
f01017d1:	39 d6                	cmp    %edx,%esi
f01017d3:	89 14 24             	mov    %edx,(%esp)
f01017d6:	72 30                	jb     f0101808 <__udivdi3+0x118>
f01017d8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01017dc:	89 e9                	mov    %ebp,%ecx
f01017de:	d3 e2                	shl    %cl,%edx
f01017e0:	39 c2                	cmp    %eax,%edx
f01017e2:	73 05                	jae    f01017e9 <__udivdi3+0xf9>
f01017e4:	3b 34 24             	cmp    (%esp),%esi
f01017e7:	74 1f                	je     f0101808 <__udivdi3+0x118>
f01017e9:	89 f8                	mov    %edi,%eax
f01017eb:	31 d2                	xor    %edx,%edx
f01017ed:	e9 7a ff ff ff       	jmp    f010176c <__udivdi3+0x7c>
f01017f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017f8:	31 d2                	xor    %edx,%edx
f01017fa:	b8 01 00 00 00       	mov    $0x1,%eax
f01017ff:	e9 68 ff ff ff       	jmp    f010176c <__udivdi3+0x7c>
f0101804:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101808:	8d 47 ff             	lea    -0x1(%edi),%eax
f010180b:	31 d2                	xor    %edx,%edx
f010180d:	83 c4 0c             	add    $0xc,%esp
f0101810:	5e                   	pop    %esi
f0101811:	5f                   	pop    %edi
f0101812:	5d                   	pop    %ebp
f0101813:	c3                   	ret    
f0101814:	66 90                	xchg   %ax,%ax
f0101816:	66 90                	xchg   %ax,%ax
f0101818:	66 90                	xchg   %ax,%ax
f010181a:	66 90                	xchg   %ax,%ax
f010181c:	66 90                	xchg   %ax,%ax
f010181e:	66 90                	xchg   %ax,%ax

f0101820 <__umoddi3>:
f0101820:	55                   	push   %ebp
f0101821:	57                   	push   %edi
f0101822:	56                   	push   %esi
f0101823:	83 ec 14             	sub    $0x14,%esp
f0101826:	8b 44 24 28          	mov    0x28(%esp),%eax
f010182a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010182e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0101832:	89 c7                	mov    %eax,%edi
f0101834:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101838:	8b 44 24 30          	mov    0x30(%esp),%eax
f010183c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0101840:	89 34 24             	mov    %esi,(%esp)
f0101843:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101847:	85 c0                	test   %eax,%eax
f0101849:	89 c2                	mov    %eax,%edx
f010184b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010184f:	75 17                	jne    f0101868 <__umoddi3+0x48>
f0101851:	39 fe                	cmp    %edi,%esi
f0101853:	76 4b                	jbe    f01018a0 <__umoddi3+0x80>
f0101855:	89 c8                	mov    %ecx,%eax
f0101857:	89 fa                	mov    %edi,%edx
f0101859:	f7 f6                	div    %esi
f010185b:	89 d0                	mov    %edx,%eax
f010185d:	31 d2                	xor    %edx,%edx
f010185f:	83 c4 14             	add    $0x14,%esp
f0101862:	5e                   	pop    %esi
f0101863:	5f                   	pop    %edi
f0101864:	5d                   	pop    %ebp
f0101865:	c3                   	ret    
f0101866:	66 90                	xchg   %ax,%ax
f0101868:	39 f8                	cmp    %edi,%eax
f010186a:	77 54                	ja     f01018c0 <__umoddi3+0xa0>
f010186c:	0f bd e8             	bsr    %eax,%ebp
f010186f:	83 f5 1f             	xor    $0x1f,%ebp
f0101872:	75 5c                	jne    f01018d0 <__umoddi3+0xb0>
f0101874:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101878:	39 3c 24             	cmp    %edi,(%esp)
f010187b:	0f 87 e7 00 00 00    	ja     f0101968 <__umoddi3+0x148>
f0101881:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101885:	29 f1                	sub    %esi,%ecx
f0101887:	19 c7                	sbb    %eax,%edi
f0101889:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010188d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101891:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101895:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101899:	83 c4 14             	add    $0x14,%esp
f010189c:	5e                   	pop    %esi
f010189d:	5f                   	pop    %edi
f010189e:	5d                   	pop    %ebp
f010189f:	c3                   	ret    
f01018a0:	85 f6                	test   %esi,%esi
f01018a2:	89 f5                	mov    %esi,%ebp
f01018a4:	75 0b                	jne    f01018b1 <__umoddi3+0x91>
f01018a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01018ab:	31 d2                	xor    %edx,%edx
f01018ad:	f7 f6                	div    %esi
f01018af:	89 c5                	mov    %eax,%ebp
f01018b1:	8b 44 24 04          	mov    0x4(%esp),%eax
f01018b5:	31 d2                	xor    %edx,%edx
f01018b7:	f7 f5                	div    %ebp
f01018b9:	89 c8                	mov    %ecx,%eax
f01018bb:	f7 f5                	div    %ebp
f01018bd:	eb 9c                	jmp    f010185b <__umoddi3+0x3b>
f01018bf:	90                   	nop
f01018c0:	89 c8                	mov    %ecx,%eax
f01018c2:	89 fa                	mov    %edi,%edx
f01018c4:	83 c4 14             	add    $0x14,%esp
f01018c7:	5e                   	pop    %esi
f01018c8:	5f                   	pop    %edi
f01018c9:	5d                   	pop    %ebp
f01018ca:	c3                   	ret    
f01018cb:	90                   	nop
f01018cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018d0:	8b 04 24             	mov    (%esp),%eax
f01018d3:	be 20 00 00 00       	mov    $0x20,%esi
f01018d8:	89 e9                	mov    %ebp,%ecx
f01018da:	29 ee                	sub    %ebp,%esi
f01018dc:	d3 e2                	shl    %cl,%edx
f01018de:	89 f1                	mov    %esi,%ecx
f01018e0:	d3 e8                	shr    %cl,%eax
f01018e2:	89 e9                	mov    %ebp,%ecx
f01018e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018e8:	8b 04 24             	mov    (%esp),%eax
f01018eb:	09 54 24 04          	or     %edx,0x4(%esp)
f01018ef:	89 fa                	mov    %edi,%edx
f01018f1:	d3 e0                	shl    %cl,%eax
f01018f3:	89 f1                	mov    %esi,%ecx
f01018f5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018f9:	8b 44 24 10          	mov    0x10(%esp),%eax
f01018fd:	d3 ea                	shr    %cl,%edx
f01018ff:	89 e9                	mov    %ebp,%ecx
f0101901:	d3 e7                	shl    %cl,%edi
f0101903:	89 f1                	mov    %esi,%ecx
f0101905:	d3 e8                	shr    %cl,%eax
f0101907:	89 e9                	mov    %ebp,%ecx
f0101909:	09 f8                	or     %edi,%eax
f010190b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010190f:	f7 74 24 04          	divl   0x4(%esp)
f0101913:	d3 e7                	shl    %cl,%edi
f0101915:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101919:	89 d7                	mov    %edx,%edi
f010191b:	f7 64 24 08          	mull   0x8(%esp)
f010191f:	39 d7                	cmp    %edx,%edi
f0101921:	89 c1                	mov    %eax,%ecx
f0101923:	89 14 24             	mov    %edx,(%esp)
f0101926:	72 2c                	jb     f0101954 <__umoddi3+0x134>
f0101928:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010192c:	72 22                	jb     f0101950 <__umoddi3+0x130>
f010192e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101932:	29 c8                	sub    %ecx,%eax
f0101934:	19 d7                	sbb    %edx,%edi
f0101936:	89 e9                	mov    %ebp,%ecx
f0101938:	89 fa                	mov    %edi,%edx
f010193a:	d3 e8                	shr    %cl,%eax
f010193c:	89 f1                	mov    %esi,%ecx
f010193e:	d3 e2                	shl    %cl,%edx
f0101940:	89 e9                	mov    %ebp,%ecx
f0101942:	d3 ef                	shr    %cl,%edi
f0101944:	09 d0                	or     %edx,%eax
f0101946:	89 fa                	mov    %edi,%edx
f0101948:	83 c4 14             	add    $0x14,%esp
f010194b:	5e                   	pop    %esi
f010194c:	5f                   	pop    %edi
f010194d:	5d                   	pop    %ebp
f010194e:	c3                   	ret    
f010194f:	90                   	nop
f0101950:	39 d7                	cmp    %edx,%edi
f0101952:	75 da                	jne    f010192e <__umoddi3+0x10e>
f0101954:	8b 14 24             	mov    (%esp),%edx
f0101957:	89 c1                	mov    %eax,%ecx
f0101959:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f010195d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0101961:	eb cb                	jmp    f010192e <__umoddi3+0x10e>
f0101963:	90                   	nop
f0101964:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101968:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010196c:	0f 82 0f ff ff ff    	jb     f0101881 <__umoddi3+0x61>
f0101972:	e9 1a ff ff ff       	jmp    f0101891 <__umoddi3+0x71>

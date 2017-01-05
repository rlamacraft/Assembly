# Assembly
My crazy adventure into doing some low-level Assembly coding.

## BEWARE

1.  Expect for this code to be hideous.
2.  I have almost certainly broken every convention there is.

## Assembling

I use an Ubuntu 64-bit virtual machine, targeting the x86 architecture. I have an alias to assemble the code (printing the done message is not really necessary as they compile in seconds):
```
assemble() {
	nasm -f elf64 $1.asm && gcc $1.o -o $1.out && echo "Assembled to "$1".out!"
}```
So, for example, I can just run `assemble quickSort`, which will assemble "quickSort.asm" into "quickSort.out", which can then be executed.

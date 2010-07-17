main:
	gcc -o osxdict -framework CoreServices -framework Foundation osxdict.m

clean:
	rm -rf osxdict

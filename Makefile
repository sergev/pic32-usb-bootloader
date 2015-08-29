
SUBDIR		= 32mxsdram fubarino maximite maximite-color \
                  mmb-mx7 pinguino-micro starter-kit ubw32

all:
		-for i in $(SUBDIR); do ${MAKE} -C $$i all; done

install:

clean:
		-for i in $(SUBDIR); do ${MAKE} -C $$i clean; done

TARGET := vhdp
LEX_FLAGS := -d
#LEX_FLAGS := 

CFLAGS += -g -O0 -DBISON_DEBUG
CXXFLAGS += -g -O0 -DBISON_DEBUG

SRC := \
	bison.tab.o \
	lexer.yy.o \
	backend.o \
	Port.o \
	Entity.o \
	main.o

.PHONY:
all: $(TARGET)

lexer.yy.cpp: vhdl.l
	lex $(LEX_FLAGS) -o $@ $^

bison.tab.cpp: vhdl.y
	bison -t -d -o $@ $^

$(TARGET): $(SRC)
	$(CXX) -o $@ $^

.PHONY:
clean:
	rm *.o *.yy.cpp *.tab.cpp *.tab.hpp $(TARGET)

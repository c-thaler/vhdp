TARGET := vhdp
#LEX_FLAGS := -d
LEX_FLAGS := 

CFLAGS += -g
CXXFLAGS += -g

#CFLAGS += -DBISON_DEBUG
#CXXFLAGS += -O0 -DBISON_DEBUG

SRC := \
	bison.tab.o \
	lexer.yy.o \
	backend.o \
	Port.o \
	Entity.o \
	Arch.o \
	main.o

.PHONY:
all: $(TARGET)

lexer.yy.cpp: vhdl.l bison.tab.cpp
	lex $(LEX_FLAGS) -o $@ vhdl.l

bison.tab.cpp: vhdl.y
	bison --report=state -t -d -o $@ $^

$(TARGET): $(SRC)
	$(CXX) -o $@ $^

.PHONY:
clean:
	rm *.o *.yy.cpp *.tab.cpp *.tab.hpp *.output $(TARGET)

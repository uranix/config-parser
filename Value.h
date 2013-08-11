#ifndef __CONFIG__VALUE_H__
#define __CONFIG__VALUE_H__

#include <string>
#include <vector>
#include <ostream>

namespace config {

struct Value {
	virtual ~Value() { }
	virtual std::ostream &print(std::ostream &) const = 0;
};

typedef std::pair<std::string, Value *> Entry;
typedef std::vector<Value *> Sequence;
typedef std::vector<Entry *> Table;

struct Number : public Value {
	double value;
	Number(double v) : value(v) { }
	virtual ~Number() { }
	virtual std::ostream &print(std::ostream &o) const {
		return o << value;
	}
};

struct Identifier : public Value {
	std::string s;
	Identifier(const std::string *v) : s(*v) { }
	virtual ~Identifier() { }
	virtual std::ostream &print(std::ostream &o) const {
		return o << s;
	}
};

struct Vector : public Value {
	const Sequence *seq;
	Vector(const Sequence *seq) : seq(seq) { }

	virtual ~Vector() { 
		destroy_seq();
		delete seq;
	}
	void destroy_seq() {
		const Sequence &t = *seq;
		for (Sequence::const_iterator i = t.begin(); i != t.end(); i++)
			delete *i;
	}
	virtual std::ostream &print(std::ostream &o) const {
		o << "[";
		const Sequence &t = *seq;
		for (Sequence::const_iterator i = t.begin(); i != t.end(); i++)
			(*i)->print(o) << ", ";
		return o << "]";
	}
};

struct Map : public Value {
	const Table *table;
	Map(const Table *table) : table(table) { }

	virtual ~Map() { 
		destroy_table();
		delete table;
	}
	void destroy_table() {
		const Table &t = *table;
		for (Table::const_iterator i = t.begin(); i != t.end(); i++) {
			delete (*i)->second;
			delete *i;
		}
	}
	std::ostream &print_table(std::ostream &o, bool newlines = false) const {
		const Table &t = *table;
		for (Table::const_iterator i = t.begin(); i != t.end(); i++) {
			o << (*i)->first << " = ";
			(*i)->second->print(o) << ", ";
			if (newlines)
				o << '\n';
		}
		return o;
	}
	virtual std::ostream &print(std::ostream &o) const {
		o << "[";
		return print_table(o) << "]";
	}
};

struct Object : public Map {
	std::string type;
	
	Object(const std::string type, 
		const Table *table) 
	: Map(table), type(type) { }

	virtual ~Object() { }

	virtual std::ostream &print(std::ostream &o) const {
		o << type << " {\n";
		return print_table(o, true) << "}\n";
	}
};

}

#endif

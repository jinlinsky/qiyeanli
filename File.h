#ifndef  __FILE_H__
#define  __FILE_H__

#include "stdlib.h"
#include "stdio.h"
#include <string>

class File
{
public:
	enum OpenMode
	{
		OM_READ		= 0x01,
		OM_WRITE	= 0x02,
		OM_APPEND	= 0x04,
		OM_BINARY	= 0x08,
	};

	enum SeekFlag
	{
		SF_CUR,
		SF_END,
		SF_SET,
	};

	/*
	constructor
	*/
	File( void );

	/*
	destructor
	*/
	virtual ~File( void );

	/*
	override read & write
	*/
	void			Read	( void* data, int size );

	void			Write	( void* data, int size );

	/*
	method
	*/
	bool			Open	( const std::string& filename, int mode );

	void			Seek	( int pos, SeekFlag flag );

	void			Close	( void );

	/*
	template
	*/
	template<typename T>
	void			Read	( T&					value )
	{
		Read((void*)&value, sizeof(T));
	}
	/* read string */
	void			Read	( std::string&			value )
	{
		int size = 0;		Read(size);

		value.clear();
		for (int i = 0; i < size; ++i)
		{
			char c;
			Read(c);
			value.append(1, c);
		}
	}

	/* read line */
	void			ReadLine( std::string&			value )
	{
		char c = 0;

		value.clear();
		while (1)
		{
			Read(c);

			if (c == '\n')
				break;

			value.append(1, c);
		}
	}

protected:
	/*
	member
	*/
	FILE*			mFile;
};

#endif//__NPFILE_H__
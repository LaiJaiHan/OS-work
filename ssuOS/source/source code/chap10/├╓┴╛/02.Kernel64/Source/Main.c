/**
 *  file    Main.c
 *  date    2009/01/02
 *  author  kkamagui 
 *          Copyright(c)2008 All rights reserved by kkamagui
 *  brief   C 언어로 작성된 커널의 엔트리 포인트 파일
 */

#include "Types.h"

// 함수 선언
void kPrintString( int iX, int iY, const char* pcString );

/**
 *  아래 함수는 C 언어 커널의 시작 부분임
 */
void Main( void )
{
    kPrintString( 0, 10, "Switch To IA-32e Mode Success~!!" );
    kPrintString( 0, 11, "IA-32e C Language Kernel Start..............[Pass]" );

	if( MemoryReadOnlyCheck( (DWORD*) 0x1FE000 ) == FALSE ) {

		 kPrintString( 0, 12, "Read from 0x1fe000 [Ok]" );
		 kPrintString( 0, 13, "while from 0x1fe000 [Ok]" );

	}
	else {

		kPrintString( 0, 12, "0x1fe000 is ReadOnly" );
	
	}

	if( MemoryReadOnlyCheck( (DWORD*) 0x1FF000 ) == TRUE) { 

		kPrintString( 0, 12, "Read from 0x1ff000 [Ok]" );
	
	}

	else {

		kPrintString( 0, 12, "0x1ff000 is ReadWrite" );
	
	}


}

/**
 *  문자열을 X, Y 위치에 출력
 */
void kPrintString( int iX, int iY, const char* pcString )
{
    CHARACTER* pstScreen = ( CHARACTER* ) 0xB8000;
    int i;
    
    // X, Y 좌표를 이용해서 문자열을 출력할 어드레스를 계산
    pstScreen += ( iY * 80 ) + iX;

    // NULL이 나올 때까지 문자열 출력
    for( i = 0 ; pcString[ i ] != 0 ; i++ )
    {
        pstScreen[ i ].bCharactor = pcString[ i ];
    }
}


void MemoryReadOnlyCheck ( DWORD* pdwCurrentAddress ){
    
    while( ( DWORD ) pdwCurrentAddress < ( DWORD ) pdwCurrentAddress + 0x1000 )
    {        
        *pdwCurrentAddress = 0x01;

        if( *pdwCurrentAddress == 0x01 )
        {
            return FALSE;
        }
        
        pdwCurrentAddress++;
    }

	return TRUE;
}


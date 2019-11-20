#include "Page.h"

void kInitializePageTables( void )
{
	PML4TENTRY* pstPML4TEntry;
	PDPTENTRY* pstPDPTEntry;
	PDENTRY* pstPDEntry;
	PTENTRY* pstP4TEntry;
	DWORD dwMappingAddress;
	
	int i;


	pstPML4TEntry = ( PML4TENTRY* ) 0x100000;
	kSetPageEntryData( &( pstPML4TEntry[ 0 ] ), 0x00, 0x101000, PAGE_FLAGS_DEFAULT,
			0 );
	for( i = 1 ; i < PAGE_MAXENTRYCOUNT ; i++ )
	{
		kSetPageEntryData( &( pstPML4TEntry[ i ] ), 0, 0, 0, 0 );
	}


	pstPDPTEntry = ( PDPTENTRY* ) 0x101000;
	for( i = 0 ; i < 64 ; i++ )
	{
		kSetPageEntryData( &( pstPDPTEntry[ i ] ), 0, 0x102000 + ( i * PAGE_TABLESIZE ), 
				PAGE_FLAGS_DEFAULT, 0 );
	}
	for( i = 64 ; i < PAGE_MAXENTRYCOUNT ; i++ )
	{
		kSetPageEntryData( &( pstPDPTEntry[ i ] ), 0, 0, 0, 0 );
	}


	kSetPageEntryData( &( pstPDPTEntry[ 64 ] ), 0, 0x142000, 
				PAGE_FLAGS_DEFAULT, 0 );
	for( i = 65 ; i < PAGE_MAXENTRYCOUNT ; i++ )
	{
		kSetPageEntryData( &( pstPDPTEntry[ i ] ), 0, 0, 0, 0 );
	}

 


	
	pstPDEntry = ( PDENTRY* ) 0x102000;
	dwMappingAddress = 0;
	for( i = 0 ; i < PAGE_MAXENTRYCOUNT * 64 ; i++ )
	{
		kSetPageEntryData( &( pstPDEntry[ i ] ),( i * ( PAGE_DEFAULTSIZE >> 20 ) ) >> 12, dwMappingAddress, PAGE_FLAGS_DEFAULT | PAGE_FLAGS_PS, 0 );
		dwMappingAddress += PAGE_DEFAULTSIZE;
		if(i == 5 ){
			kSetPageEntryData( &( pstPDEntry[ i ] ), ( i * ( PAGE_DEFAULTSIZE >> 20 ) ) >> 12, 0,  PAGE_FLAGS_DEFAULT | PAGE_FLAGS_PS , 0);
			dwMappingAddress += PAGE_DEFAULTSIZE;
		}
	}	

pstP4TEntry = (PTENTRY*) 0x142000;
	dwMappingAddress = 0x0;

	for ( i = 0 ; i< PAGE_MAXENTRYCOUNT ; i++ )
	{
		kSetPageEntryData( &( pstP4TEntry[i] ), 0x00, dwMappingAddress, PAGE_FLAGS_DEFAULT | PAGE_FLAGS_PS4, 0);
		dwMappingAddress += PAGE_SIZE_4KB;
		if ( i == 511) 
		{ 
			kSetPageEntryData( &( pstP4TEntry[i] ), 0x00, dwMappingAddress, 0x00000000, 0); // read-only, non present
			dwMappingAddress += PAGE_SIZE_4KB;
		}
	}
}



void kSetPageEntryData( PTENTRY* pstEntry, DWORD dwUpperBaseAddress,DWORD dwLowerBaseAddress, DWORD dwLowerFlags, DWORD dwUpperFlags )
{
	pstEntry->dwAttributeAndLowerBaseAddress = dwLowerBaseAddress | dwLowerFlags;
	pstEntry->dwUpperBaseAddressAndEXB = ( dwUpperBaseAddress & 0xFF ) | 
		dwUpperFlags;
}

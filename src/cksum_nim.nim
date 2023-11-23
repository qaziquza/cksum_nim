import std/[cmdline, sequtils]


var files: seq[string] = (commandlineParams()).map(readFile)
var results: seq[uint32] = repeat(0'u32,len(files))

#Refer to https://pubs.opengroup.org/onlinepubs/9699919799/utilities/cksum.html
const lookup*: array[256,uint32] = [0x00000000'u32, 0x04c11db7'u32, 0x09823b6e'u32, 0x0d4326d9'u32,
                                   0x130476dc'u32, 0x17c56b6b'u32, 0x1a864db2'u32, 0x1e475005'u32,
                                   0x2608edb8'u32, 0x22c9f00f'u32, 0x2f8ad6d6'u32, 0x2b4bcb61'u32,
                                   0x350c9b64'u32, 0x31cd86d3'u32, 0x3c8ea00a'u32, 0x384fbdbd'u32,
                                   0x4c11db70'u32, 0x48d0c6c7'u32, 0x4593e01e'u32, 0x4152fda9'u32,
                                   0x5f15adac'u32, 0x5bd4b01b'u32, 0x569796c2'u32, 0x52568b75'u32,
                                   0x6a1936c8'u32, 0x6ed82b7f'u32, 0x639b0da6'u32, 0x675a1011'u32,
                                   0x791d4014'u32, 0x7ddc5da3'u32, 0x709f7b7a'u32, 0x745e66cd'u32,
                                   0x9823b6e0'u32, 0x9ce2ab57'u32, 0x91a18d8e'u32, 0x95609039'u32,
                                   0x8b27c03c'u32, 0x8fe6dd8b'u32, 0x82a5fb52'u32, 0x8664e6e5'u32,
                                   0xbe2b5b58'u32, 0xbaea46ef'u32, 0xb7a96036'u32, 0xb3687d81'u32,
                                   0xad2f2d84'u32, 0xa9ee3033'u32, 0xa4ad16ea'u32, 0xa06c0b5d'u32,
                                   0xd4326d90'u32, 0xd0f37027'u32, 0xddb056fe'u32, 0xd9714b49'u32,
                                   0xc7361b4c'u32, 0xc3f706fb'u32, 0xceb42022'u32, 0xca753d95'u32,
                                   0xf23a8028'u32, 0xf6fb9d9f'u32, 0xfbb8bb46'u32, 0xff79a6f1'u32,
                                   0xe13ef6f4'u32, 0xe5ffeb43'u32, 0xe8bccd9a'u32, 0xec7dd02d'u32,
                                   0x34867077'u32, 0x30476dc0'u32, 0x3d044b19'u32, 0x39c556ae'u32,
                                   0x278206ab'u32, 0x23431b1c'u32, 0x2e003dc5'u32, 0x2ac12072'u32,
                                   0x128e9dcf'u32, 0x164f8078'u32, 0x1b0ca6a1'u32, 0x1fcdbb16'u32,
                                   0x018aeb13'u32, 0x054bf6a4'u32, 0x0808d07d'u32, 0x0cc9cdca'u32,
                                   0x7897ab07'u32, 0x7c56b6b0'u32, 0x71159069'u32, 0x75d48dde'u32,
                                   0x6b93dddb'u32, 0x6f52c06c'u32, 0x6211e6b5'u32, 0x66d0fb02'u32,
                                   0x5e9f46bf'u32, 0x5a5e5b08'u32, 0x571d7dd1'u32, 0x53dc6066'u32,
                                   0x4d9b3063'u32, 0x495a2dd4'u32, 0x44190b0d'u32, 0x40d816ba'u32,
                                   0xaca5c697'u32, 0xa864db20'u32, 0xa527fdf9'u32, 0xa1e6e04e'u32,
                                   0xbfa1b04b'u32, 0xbb60adfc'u32, 0xb6238b25'u32, 0xb2e29692'u32,
                                   0x8aad2b2f'u32, 0x8e6c3698'u32, 0x832f1041'u32, 0x87ee0df6'u32,
                                   0x99a95df3'u32, 0x9d684044'u32, 0x902b669d'u32, 0x94ea7b2a'u32,
                                   0xe0b41de7'u32, 0xe4750050'u32, 0xe9362689'u32, 0xedf73b3e'u32,
                                   0xf3b06b3b'u32, 0xf771768c'u32, 0xfa325055'u32, 0xfef34de2'u32,
                                   0xc6bcf05f'u32, 0xc27dede8'u32, 0xcf3ecb31'u32, 0xcbffd686'u32,
                                   0xd5b88683'u32, 0xd1799b34'u32, 0xdc3abded'u32, 0xd8fba05a'u32,
                                   0x690ce0ee'u32, 0x6dcdfd59'u32, 0x608edb80'u32, 0x644fc637'u32,
                                   0x7a089632'u32, 0x7ec98b85'u32, 0x738aad5c'u32, 0x774bb0eb'u32,
                                   0x4f040d56'u32, 0x4bc510e1'u32, 0x46863638'u32, 0x42472b8f'u32,
                                   0x5c007b8a'u32, 0x58c1663d'u32, 0x558240e4'u32, 0x51435d53'u32,
                                   0x251d3b9e'u32, 0x21dc2629'u32, 0x2c9f00f0'u32, 0x285e1d47'u32,
                                   0x36194d42'u32, 0x32d850f5'u32, 0x3f9b762c'u32, 0x3b5a6b9b'u32,
                                   0x0315d626'u32, 0x07d4cb91'u32, 0x0a97ed48'u32, 0x0e56f0ff'u32,
                                   0x1011a0fa'u32, 0x14d0bd4d'u32, 0x19939b94'u32, 0x1d528623'u32,
                                   0xf12f560e'u32, 0xf5ee4bb9'u32, 0xf8ad6d60'u32, 0xfc6c70d7'u32,
                                   0xe22b20d2'u32, 0xe6ea3d65'u32, 0xeba91bbc'u32, 0xef68060b'u32,
                                   0xd727bbb6'u32, 0xd3e6a601'u32, 0xdea580d8'u32, 0xda649d6f'u32,
                                   0xc423cd6a'u32, 0xc0e2d0dd'u32, 0xcda1f604'u32, 0xc960ebb3'u32,
                                   0xbd3e8d7e'u32, 0xb9ff90c9'u32, 0xb4bcb610'u32, 0xb07daba7'u32,
                                   0xae3afba2'u32, 0xaafbe615'u32, 0xa7b8c0cc'u32, 0xa379dd7b'u32,
                                   0x9b3660c6'u32, 0x9ff77d71'u32, 0x92b45ba8'u32, 0x9675461f'u32,
                                   0x8832161a'u32, 0x8cf30bad'u32, 0x81b02d74'u32, 0x857130c3'u32,
                                   0x5d8a9099'u32, 0x594b8d2e'u32, 0x5408abf7'u32, 0x50c9b640'u32,
                                   0x4e8ee645'u32, 0x4a4ffbf2'u32, 0x470cdd2b'u32, 0x43cdc09c'u32,
                                   0x7b827d21'u32, 0x7f436096'u32, 0x7200464f'u32, 0x76c15bf8'u32,
                                   0x68860bfd'u32, 0x6c47164a'u32, 0x61043093'u32, 0x65c52d24'u32,
                                   0x119b4be9'u32, 0x155a565e'u32, 0x18197087'u32, 0x1cd86d30'u32,
                                   0x029f3d35'u32, 0x065e2082'u32, 0x0b1d065b'u32, 0x0fdc1bec'u32,
                                   0x3793a651'u32, 0x3352bbe6'u32, 0x3e119d3f'u32, 0x3ad08088'u32,
                                   0x2497d08d'u32, 0x2056cd3a'u32, 0x2d15ebe3'u32, 0x29d4f654'u32,
                                   0xc5a92679'u32, 0xc1683bce'u32, 0xcc2b1d17'u32, 0xc8ea00a0'u32,
                                   0xd6ad50a5'u32, 0xd26c4d12'u32, 0xdf2f6bcb'u32, 0xdbee767c'u32,
                                   0xe3a1cbc1'u32, 0xe760d676'u32, 0xea23f0af'u32, 0xeee2ed18'u32,
                                   0xf0a5bd1d'u32, 0xf464a0aa'u32, 0xf9278673'u32, 0xfde69bc4'u32,
                                   0x89b8fd09'u32, 0x8d79e0be'u32, 0x803ac667'u32, 0x84fbdbd0'u32,
                                   0x9abc8bd5'u32, 0x9e7d9662'u32, 0x933eb0bb'u32, 0x97ffad0c'u32,
                                   0xafb010b1'u32, 0xab710d06'u32, 0xa6322bdf'u32, 0xa2f33668'u32,
                                   0xbcb4666d'u32, 0xb8757bda'u32, 0xb5365d03'u32, 0xb1f740b4'u32]

# Algorithm largely from CRC Calculator by Francisco Javier Lana Romero
# Reference was also made to https://pubs.opengroup.org/onlinepubs/9699919799/utilities/cksum.html

for x,i in files:
    for j in i:
        results[x] = (results[x] shl 8) xor lookup[uint8((results[x] shr 24) and 0xFF'u32) xor uint8(j)]
    var l: uint64=uint64(len(i)) 
    var c: uint8
    while l>0:
        c = uint8(l and 0xFF'u64)
        l = l shr 8
        results[x] = (results[x] shl 8) xor lookup[uint8((results[x] shr 24) and 0xFF'u32) xor c]

    echo $(not results[x]), " ", $len(i), " ", $commandLineParams()[x]

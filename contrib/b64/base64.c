#include <stdint.h>
#include <stdlib.h>
#include <string.h>

static const char b64_enc_table[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "abcdefghijklmnopqrstuvwxyz"
    "0123456789+/";

/* Encodes `len` bytes from `in` into a freshly malloc'd, null-terminated
 * Base64 string. Caller must free() the result. Returns NULL on alloc fail. */
char *base64_encode(const uint8_t *in, size_t len) {
    size_t out_len = 4 * ((len + 2) / 3);      /* ceil(len/3) * 4 */
    char *out = malloc(out_len + 1);           /* +1 for '\0'     */
    if (!out) return NULL;

    size_t i, j;
    for (i = 0, j = 0; i + 2 < len; i += 3) {
        uint32_t n = ((uint32_t)in[i] << 16)
                   | ((uint32_t)in[i + 1] << 8)
                   |  (uint32_t)in[i + 2];
        out[j++] = b64_enc_table[(n >> 18) & 0x3F];
        out[j++] = b64_enc_table[(n >> 12) & 0x3F];
        out[j++] = b64_enc_table[(n >>  6) & 0x3F];
        out[j++] = b64_enc_table[ n        & 0x3F];
    }

    /* Handle the trailing 1 or 2 bytes. */
    size_t rem = len - i;
    if (rem == 1) {
        uint32_t n = (uint32_t)in[i] << 16;
        out[j++] = b64_enc_table[(n >> 18) & 0x3F];
        out[j++] = b64_enc_table[(n >> 12) & 0x3F];
        out[j++] = '=';
        out[j++] = '=';
    } else if (rem == 2) {
        uint32_t n = ((uint32_t)in[i] << 16)
                   | ((uint32_t)in[i + 1] << 8);
        out[j++] = b64_enc_table[(n >> 18) & 0x3F];
        out[j++] = b64_enc_table[(n >> 12) & 0x3F];
        out[j++] = b64_enc_table[(n >>  6) & 0x3F];
        out[j++] = '=';
    }

    out[j] = '\0';
    return out;
}

/* -1 = invalid, -2 = padding ('='). Index by unsigned byte value. */
static const int8_t b64_dec_table[256] = {
    ['A']= 0,['B']= 1,['C']= 2,['D']= 3,['E']= 4,['F']= 5,['G']= 6,['H']= 7,
    ['I']= 8,['J']= 9,['K']=10,['L']=11,['M']=12,['N']=13,['O']=14,['P']=15,
    ['Q']=16,['R']=17,['S']=18,['T']=19,['U']=20,['V']=21,['W']=22,['X']=23,
    ['Y']=24,['Z']=25,['a']=26,['b']=27,['c']=28,['d']=29,['e']=30,['f']=31,
    ['g']=32,['h']=33,['i']=34,['j']=35,['k']=36,['l']=37,['m']=38,['n']=39,
    ['o']=40,['p']=41,['q']=42,['r']=43,['s']=44,['t']=45,['u']=46,['v']=47,
    ['w']=48,['x']=49,['y']=50,['z']=51,['0']=52,['1']=53,['2']=54,['3']=55,
    ['4']=56,['5']=57,['6']=58,['7']=59,['8']=60,['9']=61,['+']=62,['/']=63,
    ['=']=-2,
    /* every other entry is implicitly 0 — fix that below at runtime,
     * or initialise to -1 explicitly. See note. */
};

/* Decodes a null-terminated Base64 string. On success returns a malloc'd
 * buffer and writes the byte count to *out_len. Returns NULL on error. */
uint8_t *base64_decode(const char *in, size_t in_len, size_t *out_len) {
    if (in_len % 4 != 0) return NULL;          /* must be a multiple of 4 */
    if (in_len == 0) { *out_len = 0; return malloc(1); }

    size_t pad = 0;
    if (in[in_len - 1] == '=') pad++;
    if (in[in_len - 2] == '=') pad++;

    size_t cap = (in_len / 4) * 3 - pad;
    uint8_t *out = malloc(cap ? cap : 1);
    if (!out) return NULL;

    size_t i, j = 0;
    for (i = 0; i < in_len; i += 4) {
        int8_t a = b64_dec_table[(uint8_t)in[i]];
        int8_t b = b64_dec_table[(uint8_t)in[i + 1]];
        int8_t c = b64_dec_table[(uint8_t)in[i + 2]];
        int8_t d = b64_dec_table[(uint8_t)in[i + 3]];

        if (a == -1 || b == -1) { free(out); return NULL; }

        uint32_t n = ((uint32_t)a << 18) | ((uint32_t)b << 12);
        out[j++] = (n >> 16) & 0xFF;

        if (c != -2) {                          /* not padding */
            n |= (uint32_t)c << 6;
            out[j++] = (n >> 8) & 0xFF;
            if (d != -2) {
                n |= (uint32_t)d;
                out[j++] = n & 0xFF;
            }
        }
    }

    *out_len = j;
    return out;
}

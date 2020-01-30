# in get_pbin_bytes function definition

writesum = pbin_io.write(self.header)
writesum += pbin_io.write(self.ibin_offsets)
#insert here ===========
pad = create_string_buffer(pbin_obj.header_pad_size)
writesum += pbin_io.write(pad)
#=======================
for ibin in self.ibins:
    writesum += pbin_io.write(ibin)
# after write header, offsets, bins, insert pad
pad = create_string_buffer(0 if (writesum % 8) == 0 else (8 - (writesum % 8))) # 8 bytes aligned
writesum += pbin_io.write(pad)

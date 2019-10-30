using BinaryMatrixLoading
using Test
using Random

input = rand(Float32, 10, 10)
write_matrix(input, "test.bin")
input2 = read_bin_matrix("test.bin")
@test input == input2

rm("test.bin")
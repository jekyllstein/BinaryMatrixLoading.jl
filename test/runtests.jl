using BinaryMatrixLoading
using Test
using Random

input = rand(Float32, 10, 10)
write_matrix(input, "test.bin")
input2 = read_bin_matrix("test.bin")
@test input == input2

(n, m) = read_bin_matrix_dims("test.bin")
@test size(input) == (n, m)

v = read_bin_matrix_col("test.bin", 5)
@test v == input[:, 5]

rows = rand(1:10, 5)
cols = rand(1:10, 5)
m = read_bin_matrix_inds("test.bin", rows, cols)
@test reduce(&, m .== view(input, rows, cols))

rm("test.bin")
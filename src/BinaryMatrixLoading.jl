module BinaryMatrixLoading

"""
	write_matrix(input::Matrix{Float32}, filename::AbstractString, overwrite::Bool = false)

Write a Float32 matrix in binary representation to file.  

There is a leading set of integers which will help the read function 
determine how to reconstruct the array.  The encoding is as follows: 
- First value N indicates how many rows are in the array.  
- The second value M indicates how many columns are in the array.  
- All of the following lines are the data.

!!! note
    If the filename exists already then the third argument must be set to `true` 
    or the call will result in an error.


"""
function write_matrix(input::Matrix{Float32}, filename::AbstractString, overwrite::Bool = false)
	if isfile(filename)
		if overwrite
			rm(filename)
		else
			error("$filename is an existing file, if you wish to overwrite it call `write_matrix` with the 3rd argument true")
		end
	end
	f = open(filename, "a")
	(N, M) = size(input)
	write(f, N)
	write(f, M)
	if N*M != 0
		write(f, input)
	end
	close(f)
end

"""
	M::Matrix{Float32} = read_bin_matrix(filename::AbstractString, printdims::Bool = false)

Read a Float32 matrix written to file generated with `write_matrix`.

# Examples
```julia-repl
julia> using BinaryMatrixLoading
julia> input = rand(Float32, 10, 10);
julia> write_matrix(input, "test.bin")
julia> input2 = read_bin_matrix("test.bin");
julia> @assert input == input2
```
"""
function read_bin_matrix(filename::AbstractString, printdims::Bool = false)
	#read array in binary form from a file.  
	f = open(filename)
	#get length of params array
	n = read(f, Int64)
	m = read(f, Int64)
	printdims && println("Got the following array dimensions: $n rows and $m columns")
	out = read!(f, Matrix{Float32}(undef, n, m))
end

"""
	(n::Int64, m::Int64) = read_bin_matrix_dims(filename::AbstractString, printdims::Bool = false)

Read the dimensions Float32 matrix written to file generated with `write_matrix`.

# Examples
```julia-repl
julia> using BinaryMatrixLoading
julia> input = rand(Float32, 10, 10);
julia> write_matrix(input, "test.bin")
julia> (n, m) = read_bin_matrix_dims("test.bin");
julia> @assert size(input) == (n, m)
```
"""
function read_bin_matrix_dims(filename::AbstractString)
	#read array in binary form from a file.  
	f = open(filename)
	#get length of params array
	n = read(f, Int64)
	m = read(f, Int64)
	(n, m)
end

"""
	v::Vector{Float64} = read_bin_matrix_col(filename::AbstractString, col::Int64, printdims::Bool = false)

Read column col from a Float32 matrix written to file generated with `write_matrix`.

# Examples
```julia-repl
julia> using BinaryMatrixLoading
julia> input = rand(Float32, 10, 10);
julia> write_matrix(input, "test.bin")
julia> v = read_bin_matrix_col("test.bin", 5);
julia> @assert v == input[:, 5]
```
"""
function read_bin_matrix_col(filename::AbstractString, col::Int64, printdims::Bool = false)
	#read array in binary form from a file.  
	f = open(filename)
	#get length of params array
	n = read(f, Int64)
	m = read(f, Int64)
	printdims && println("Got the following array dimensions: $n rows and $m columns")
	
	nbytes = (col-1)*n*4
	skip(f, nbytes) 
	v = read!(f, Vector{Float32}(undef, n))
end

"""
	m::Matrix{Float32} = read_bin_matrix_inds(filename::AbstractString, rows::AbstractVector{Int64}, cols::AbstractVector{Int64}, printdims::Bool = false)

Read a submatrix with rows and cols from a Float32 matrix written to file generated with `write_matrix`.

# Examples
```julia-repl
julia> using BinaryMatrixLoading
julia> input = rand(Float32, 10, 10);
julia> write_matrix(input, "test.bin")
julia> rows = rand(1:10, 5)
julia> cols = rand(1:10, 5)
julia> m = read_bin_matrix_inds("test.bin", rows, cols)
julia> @assert reduce(&, m .== view(input, rows, cols))
```
"""
function read_bin_matrix_inds(filename::AbstractString, rows::AbstractVector{Int64}, cols::AbstractVector{Int64}, printdims::Bool = false)
	#read array in binary form from a file.  
	f = open(filename)
	#get length of params array
	n = read(f, Int64)
	m = read(f, Int64)
	printdims && println("Got the following array dimensions: $n rows and $m columns")
	finalout = Matrix{Float32}(undef, length(rows), length(cols))	
	colout = Vector{Float32}(undef, n)
	startpos = position(f)
	for (i, col) in enumerate(cols)
		nbytes = (col-1)*n*4
		skip(f, nbytes) 
		read!(f, colout)
		view(finalout, :, i) .= view(colout, rows)
		seek(f, startpos)
	end
	return finalout
end

export write_matrix, read_bin_matrix, read_bin_matrix_dims, read_bin_matrix_col, read_bin_matrix_inds

end # module

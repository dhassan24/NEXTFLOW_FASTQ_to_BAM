
// ─────────────────────────────────────────
// hisat.nf - Mouse chr1 alignment pipeline
// ─────────────────────────────────────────

params.genome = "chr1.fa.gz"
params.input_file = "SRR1552445.fastq.gz"


// ─────────────────────────────────────────
// PROCESS 1: Unzip the FASTQ file
// ─────────────────────────────────────────

process unzipFastq {
        publishDir "results/unzipped", mode: 'copy'

        input:
        path gz_file

        // The input is the zipped fastq file you want to unzip

        output:
        path "${gz_file.simpleName}"  // e.g. SRR1552445
        // The output path: The * is a wildcard that captures any file
        // created in the process working directory. It will capture the
        // unzipped file produced by gzip -dc lin

        script:
        """

        gzip -dc ${gz_file} > ${gz_file.simpleName}

        """
        // This is the main script/commands: unzip the gz file
}


// ─────────────────────────────────────────
// PROCESS 2: Index the reference genome
// ─────────────────────────────────────────

process indexGenome {
	publishDir "results/genome_index", mode: 'copy'

	input:
	path genome_gz

	output:
	path "chr1_index*" // HISAT2 creates multiple index files

	script:
	""" 

	gzip -dc ${genome_gz} > chr1.fa
	hisat2-build chr1.fa chr1_index

	""" 
}


// ─────────────────────────────────────────
// PROCESS 3: FastQC on unzipped FASTQ
// ─────────────────────────────────────────

process fastqc { 
	publishDir "results/fastqc", mode: 'copy'

	input:
	path read

	output:
	path "*.html"
	path "*.zip"

	script:
	""" 

	fastqc ${read}

	"""
}

// ─────────────────────────────────────────
// PROCESS 4: ALIGN WITH HISAT2
// ─────────────────────────────────────────

process hisat2Align {
	publishDir "results/aligned", mode: 'copy'

	input:
	path read       // unzipped fastq from unzipFastq
	path index_files    // index files from indexGenome

	output:
	path "*.sam"

	script:
	""" 

	hisat2 -x chr1_index -U ${read} -S ${read.simpleName}.sam

	"""
}


// ─────────────────────────────────────────
// PROCESS 5: CONVERT SAME TO BAM
// ─────────────────────────────────────────

process SamToBam {
        publishDir "results/bam", mode: 'copy'

        input:
        path sam_file       // .SAM FILE FROM HISAT2 ALIGNMENT

        output:
        path "*.bam"

        script:
        """

        samtools view -bS ${sam_file} | samtools sort -o ${sam_file.simpleName}.bam
	samtools index ${sam_file.simpleName}.bam

        """
}



// ─────────────────────────────────────────
// WORKFLOW: Wire everything together
// ─────────────────────────────────────────

workflow {
	// Create channels for inputs
	fastq_gz_ch = Channel.fromPath(params.input_file)
	genome_gz_ch = Channel.fromPath(params.genome)


	// Step 1: Unzip the fastq
	unzipped_ch = unzipFastq(fastq_gz_ch)

	// Step 2: Index the genome (runs in parallel with fastqc)
	index_ch = indexGenome(genome_gz_ch)

	// Step 3: fastqc and hisat2 both take the unzipped fastq
	fastqc(unzipped_ch)

	// Step 4: Align -> produces .sam
	sam_ch = hisat2Align(unzipped_ch, index_ch.collect())

	// Step 5: SAM to BAM file
	SamToBam(sam_ch)
}


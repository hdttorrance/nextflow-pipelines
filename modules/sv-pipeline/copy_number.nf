params.run = true

process copy_number_v2 {
    memory '4G'
    tag "$samplename $egan_id"
    cpus 2
    disk '29 GB'
    scratch '/tmp'
    stageInMode 'copy'
    stageOutMode 'rsync'
    time '1000m'
    container "copy_number_v2"
    maxForks 30
    // containerOptions = "--bind /home/ubuntu"
    // errorStrategy 'terminate'
    errorStrategy { task.attempt <= 3 ? 'retry' : 'ignore' }
    publishDir "${params.outdir}/copy_number/", mode: 'symlink', overwrite: true 
    maxRetries 3

    when:
    params.run
     
    input: 
    tuple val(samplename), val(egan_id), file(hist_root_file), file(samplename_gt_vcf)
    
    output: 
    tuple val(samplename), file("${samplename}.cn.vcf"), emit: samplename_cn_vcf

    script:
    """ 
export ROOTSYS=/root
export MANPATH=/root/man:/usr/local/man:/usr/local/share/man:/usr/share/man
export USER_PATH=/home/ubuntu/error/speedseq/bin/:/home/ubuntu/anaconda3/envs/py2/bin:/home/ubuntu/anaconda3/condabin:/usr/local/go/bin:/home/ubuntu/error/root/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/ubuntu/go/bin:/home/ubuntu/go/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export LD_LIBRARY_PATH=/root/lib:/.singularity.d/libs
export LIBPATH=/root/lib
export JUPYTER_PATH=/root/etc/notebook
export DYLD_LIBRARY_PATH=/root/lib
export PYTHONPATH=/root/lib
export SHLIB_PATH=/root/lib
export CMAKE_PREFIX_PATH=/root
export CLING_STANDARD_PCH=none

export PATH=/root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/speedseq/bin:/miniconda/bin:\$PATH

    eval \"\$(conda shell.bash hook)\"
    conda activate py2

   create_coordinates \\
      -i ${samplename_gt_vcf} \\
      -o coordinates.txt

    svtools copynumber \\
      -i ${samplename_gt_vcf} \\
      -s ${samplename} \\
      --cnvnator cnvnator \\
      -w 100 \\
      -r ${hist_root_file} \\
      -c coordinates.txt \\
      > ${samplename}.cn.vcf
    """
}

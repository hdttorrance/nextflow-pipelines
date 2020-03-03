nextflow.preview.dsl=2
params.runtag = 'ibd_vqsr'
params.run_strip = false
params.run_vep = false
params.run_vqsr = false

params.vcfs_dir = "/lustre/scratch118/humgen/hgi/projects/ibdx10/variant_calling/joint_calling/vcfs_concatenated"
Channel.fromPath("${params.vcfs_dir}/*.vcf.gz")
	.set{ch_vcfs_gz}
Channel.fromPath("${params.vcfs_dir}/*.vcf.gz.csi")
	.set{ch_vcfs_gz_csi}

include strip_vcf from '../modules/variant_calling/strip_vcf.nf' params(run: true, outdir: params.outdir)
//include vep_vcf from '../modules/variant_calling/strip_vcf.nf' params(run: true, outdir: params.outdir)
//include vqsr_vcf from '../modules/variant_calling/vqsr_vcf.nf' params(run: true, outdir: params.outdir)

workflow {
    ch_vcfs_gz
	.map{vcf -> tuple(vcf.getSimpleName(),vcf)}
	.combine(
	ch_vcfs_gz_csi
	    .map{csi -> tuple(csi.getSimpleName(),csi)}, by: 0)
	.take(4)
	.set{ch_name_vcf_csi}
    
    ch_name_vcf_csi.view()

    if (params.run_strip) {
	strip_vcf(ch_name_vcf_csi)
	strip_vcf.out.name_vcf_csi.view()
//	
//	if (params.run_vep) {
//	    vep_vcf(strip_vcf.out.)
//	    
//	    if (params.run_vqsr) {
//		vqsr_vcf()
//	    }
//	}
    }
}








//Channel.fromPath("${baseDir}/../../inputs/S04380110_Padded_merged.bed")
//	.set{ch_intersect_bed}


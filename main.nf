#!/usr/bin/env nextflow

// Folder with individual  cohort Tumor_Sample_Barcode files (1 file == 1 case-control pair)
Channel
    .fromPath("${params.maf_folder}",  type: "dir" )
    .ifEmpty { exit 1, "Path to input --maf_folder is incorrect or the folder contains no .maf files." }
    .set { maf_folder_channel}

process run_mutsig_analysis {
  tag "$maf_folder"
  publishDir params.outdir, mode: 'copy'
  container 'lifebitai/mtsgmftls:101'

  input:
  file(maf_folder) from maf_folder_channel

  output:
  file("{MultiQC,multiqc_report.html}") into results

  script:
  """
  # copy the docker scripts into pwd
  mkdir scripts
  cp -r /opt/conda/envs/mutationsignatures-nf/scripts/*Rmd scripts/

  # copy the maf files into pwd
  mkdir mafs/
  cp ${maf_folder}/* mafs/
  mv  mafs/ scripts/mafs/

  cd scripts

  # copy the rmarkdown into the workdir
  R -e "rmarkdown::render('maftools_report.Rmd', output_file='maftools_report.html')"

  cd ..

  mkdir MultiQC && mv scripts/maftools_report.html MultiQC/multiqc_report.html
  """
}
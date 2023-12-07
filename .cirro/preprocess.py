#!/usr/bin/env python3

from cirro.helpers.preprocess_dataset import PreprocessDataset
import pandas as pd

def make_sample_table(ds: PreprocessDataset) -> pd.DataFrame:

    ds.logger.info("Files annotated in the dataset:")
    ds.logger.info(ds.files)

    # Filter out any index files that may have been uploaded
    ds.logger.info("Filtering out any index reads")
    ds.files = ds.files.loc[
        ds.files.apply(
            lambda r: r.get('readType', 'R') == 'R',
            axis=1
        )
    ]

    # Add a lane column if it is not present
    if "lane" not in ds.files.columns.values:
        ds.logger.info("Adding dummy lane column")
        ds.files = ds.files.assign(lane=1)

    # Make a wide sample_table
    ds.logger.info("Pivoting to wide format")
    sample_table = ds.wide_samplesheet(
        index=["sampleIndex", "sample", "lane"],
        columns="read",
        values="file",
        column_prefix="fastq_"
    ).sort_values(
        by="sample"
    )
    assert sample_table.shape[0] > 0, "No files detected -- there may be an error with data ingest"
    ds.logger.info(sample_table.to_csv(index=None))

    # Only keep the expected columns, setting sample -> group
    ds.logger.info("Rearranging the columns")
    sample_table = sample_table.reindex(
        columns=["sample", "fastq_1", "fastq_2"]
    )
    ds.logger.info(sample_table.to_csv(index=None))

    return sample_table


def setup_input_parameters(ds: PreprocessDataset):

    # If the user selects a "Custom" genome,
    # then the `fasta` parameter will be used
    if ds.params["genome"] == "Custom":
        # Set params.genome to False
        ds.add_param("genome", False, overwrite=True)
        # Make sure that params.fasta was provided by the user
        msg = "Must provide custom genome FASTA from references"
        assert ds.params.get("fasta") is not None, msg

    # Removing empty spaces on project_name
    # ds.add_param("project_name", ds.params["project_name"].replace(" ", "-"), overwrite=True)

    # If the user did not select a custom Cell Markers DB CSV, use the default
    if ds.params.get("input_cell_markers_db") is None:
        ds.add_param(
            "input_cell_markers_db",
            "./assets/cell_markers_database.csv"
        )

    # If the user did not select a custom Meta-Program CSV, use the default
    if ds.params.get("input_meta_programs_db") is None:
        ds.add_param(
            "input_meta_programs_db",
            "./assets/meta_programs_database.csv"
        )


if __name__ == "__main__":

    ds = PreprocessDataset.from_running()

    setup_input_parameters(ds)

    #ds.logger.info("Printing out samplesheet columns")
    #ds.logger.info(ds.samplesheet.columns)

    # Make a sample table of the input data
    sample_table = make_sample_table(ds)
    sample_table.to_csv("sample_table.csv", index=None)

    # log
    ds.logger.info(ds.params)

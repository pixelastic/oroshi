use anyhow::{Context, Result};
use clap::Parser;
use hound::WavReader;
use parakeet_rs::{ParakeetTDT, Transcriber};
use std::path::{Path, PathBuf};

#[derive(Parser)]
#[command(
    name = "speech-to-text",
    about = "Transcribe audio files to text using Parakeet v3",
    version
)]
struct Cli {
    /// Path to the audio file to transcribe
    #[arg(value_name = "FILE")]
    file: PathBuf,
}

// Convert the input file into an array of vectors, to pass to Parakeet
fn read_samples(file: &Path) -> Result<Vec<f32>> {
    if !file.exists() {
        anyhow::bail!("Audio file not found: {}", file.display());
    }

    let mut reader = WavReader::open(file)?;
    let spec = reader.spec();

    // Convert the samples into vectors (they can be stored either as int or float in the input
    // file)
    let samples: Vec<f32> = match spec.sample_format {
        hound::SampleFormat::Int => reader
            .samples::<i16>()
            .map(|s| s.map(|v| v as f32 / 32768.0))
            .collect::<Result<Vec<_>, _>>()
            .context("Failed to read audio samples")?,
        hound::SampleFormat::Float => reader
            .samples::<f32>()
            .collect::<Result<Vec<_>, _>>()
            .context("Failed to read audio samples")?,
    };

    Ok(samples)
}

// Load a Parakeet instance
fn load_parakeet() -> Result<ParakeetTDT> {
    let model_path = PathBuf::from("/home/tim/local/src/parakeet");

    if !model_path.exists() {
        anyhow::bail!(
            "Model directory not found: {}\n\
             \n\
             Please place the Parakeet model files in this directory.\n\
             \n\
             You can download them from:\n\
             - URL: https://blob.handy.computer/parakeet-v3-int8.tar.gz \n\
             - Or copy from: Dropbox/tim/configs/models/parakeet",
            model_path.display()
        );
    }

    let parakeet = ParakeetTDT::from_pretrained(
        model_path.to_str().context("Invalid model path")?,
        None,
    )
    .context("Failed to load Parakeet model")?;

    Ok(parakeet)
}

fn main() -> Result<()> {
    let args = Cli::parse();

    let samples = read_samples(&args.file)?;
    let mut parakeet = load_parakeet()?;

    let result = parakeet
        .transcribe_samples(samples, 16000, 1, None)
        .context("Failed to transcribe audio")?;

    println!("{}", result.text.trim());

    Ok(())
}

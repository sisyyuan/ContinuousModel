#  Common rules of the organization and architecture of cis-regulatory modules in the human and mouse genomes 

##  Overview

By analyzing our recently predicted unprecedentedly complete maps of CRMs and constituent TFBSs in the human and mouse genomes, we reveal static common rules for the landscape and organization of CRMs on the human and mouse chromosomes as well as for the architecture inside of CRMs in terms of their constituent TFBSs and inter-TFBSs spacers. These findings will significantly advance the understanding of regulatory genomes and have a profound impact on the field of gene transcriptional regulation research.


## 📄 Abstract

**Background:** We have recently predicted comprehensive maps of cis-regulatory modules (CRMs) and constituent transcription factor (TF) binding sites (TFBSs) in the human and mouse genomes, enabling us to investigate the static organization and architecture of the CRMs in both genomes. 
**Results:** We reveal common rules of the static organization and architecture of CRMs in the two genomes. 1) The numbers and lengths of CRMs and genes on chromosomes are correlated with the sizes of chromosomes. 2) CRMs are unevenly but correlatedly distributed with genes along chromosomes. 3) Activation probabilities of CRMs and expression levels of genes within the same topologically associating domain (TAD) show stronger correlation than those outside the TAD. 4) CRMs near the two ends of a TAD tend to have higher TBFS density than those in the middle of the TAD. 5) CRMs are slightly biasedly distributed downstream of their nearest transcription start sites that they do not necessarily regulate. 6) A small but considerable portion (~7%) of CRMs overlap core promoters while the majority (~93%) others do not; thus, CRMs can be classified into core promoter-containing (CPC) and core promoter-lacking (CPL) categories. 7) Most (>90%) of core promoters overlap CRMs, only a small portion (<10%) exist alone. 8) CPC CRMs tend to be longer and contain higher density of TFBSs than CPL CRMs. 9) TFBSs in a CRM exhibit extensive overlaps, forming longer TFBS islands. 10) TFBS islands comprise less than half of CRMs in length. 11) Spacers between TFBS islands are subject to similar evolutionary constraints as TFBS islands and less likely overlap DNase I hypersensitive sites and TF footprints than TFBS islands, suggesting that they may play roles in transcriptional regulation other than direct TF binding.


---

##  Project Structure

```
.
├── code/                     # Data Analyses
│   ├── train.py
│   ├── test.py
│   ├── train.py
│   ├── test.py
│   ├── train.py
│   ├── test.py
│   ├── train.py
│   ├── test.py
│   ├── train.py
│   ├── test.py
│   ├── train.py
│   ├── test.py

├── data/
│   ├── Human/
│   ├── Mouse/
└── README.md
```

---

## 📊 Data Description

Each dataset (`.bed`) contains:

* chromosome
* start site
* end site

Additional file:

* `name2id`: maps entity IDs to real herb/gene names

---


## Results

The rules governing the static organization and architecture of CRMs in the human and mouse genomes are highly conserved.

---

## 🔬 Key Contributions

* 🚀 First integration of **LLM semantic knowledge + TWKG topology**
* 🧠 Captures **cross-domain knowledge (TCM + modern biomedicine)**
* ⚙️ Introduces **adaptive parameter updating mechanism**
* 📊 Achieves **state-of-the-art HTI prediction performance**

---

## 📚 Citation

If you find this work useful, please cite:

```bibtex
@article{XXX2026,
  title={Common rules of the organization and architecture of cis-regulatory modules in the human and mouse genomes},
  author={XXX},
  journal={XXX},
  year={2026}
}
```



---

## ⭐ Star This Repo

If you find this project helpful, please consider giving it a ⭐!

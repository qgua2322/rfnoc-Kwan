library(ggplot2)
library(ggthemes)
library(reshape2)

NUM_PACKETS_TO_TAKE <- 25000

load_data <- function(s,n) {
    tmp <- read.csv(paste(s," rawdata.csv",sep=""),header=F,sep=",",stringsAsFactors=F)
    
    # remove outliers
    tmp <- tmp[tmp$V2 < 400,]

    tmp <- tmp[sample(nrow(tmp),n),]
    colnames(tmp) <- c("id","sample_latency","packet_latency")
    tmp$spp <- as.factor(s)
    print(paste("SPP = ",s,", NUM PACKETS = ",nrow(tmp),sep=""))
    tmp
}

# load datasets
spps <- c(64,128,256)
data <- NULL
for (spp in spps) {
    if (is.null(data)) {
        data <- load_data(spp,NUM_PACKETS_TO_TAKE)
    } else {
        data <- rbind(data,load_data(spp,NUM_PACKETS_TO_TAKE))
    }
}

data$sample_latency_us <- data$sample_latency * 5 / 1e3
data$packet_latency_us <- data$packet_latency * 5 / 1e3


head(data)

pdf("spp_sample_latency_histograms.pdf",width=12,height=7)
ggplot(data,aes(sample_latency_us,fill=spp)) +
    geom_density(alpha=0.2) +
    xlab("Sample Latency (us)") +
    ylab("Density Count") +
    # scale_fill_grey() +
    # scale_fill_manual(values = c("LSTM Prediction Error     " = "white", "Naive Prediction Error     " = "#000000")) +
    theme_minimal() +
    # theme_bw() +
    theme(
        legend.position = "top",
        # legend.title = element_blank(),
        legend.key.width=unit(0.8,"cm"),
        legend.key.height=unit(0.8,"cm"),
        axis.text.x=element_text(size=12,angle=0,hjust=0.5,vjust=0),
        axis.text.y=element_text(size=12,angle=0,hjust=1),
        axis.title.x = element_text(size=12,angle=0,hjust=.5,vjust=0,face="plain"),
        axis.title.y = element_text(size=12,hjust=.5,vjust=.5,face="plain"),
        legend.text=element_text(size=16)
    )

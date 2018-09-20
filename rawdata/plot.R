library(ggplot2)
library(ggthemes)
library(reshape2)

NUM_PACKETS_TO_TAKE <- 25000

unroll <- function(x,s) {
    x <- x[rep(row.names(x), s),]
    x
}

load_data <- function(s,n) {
    tmp <- read.csv(paste(s," rawdata.csv",sep=""),header=F,sep=",",stringsAsFactors=F)
    
    # replicate rows for packet to sample df transformation
    tmp <- unroll(tmp,s)

    # tmp <- tmp[sample(nrow(tmp),n),]
    # remove single anomalous point currently in 44
    tmp <- tmp[tmp$V2 < 500,]
    colnames(tmp) <- c("id","sample_latency","packet_latency")
    tmp$spp <- as.factor(s)
    print(paste("SPP = ",s,", NUM SAMPLES = ",nrow(tmp),sep=""))
    tmp
}

# load datasets
spps <- c(44,48,64,128,256)
#spps <- c(44,48)
data <- NULL
for (spp in spps) {
    if (is.null(data)) {
        data <- load_data(spp)
    } else {
        data <- rbind(data,load_data(spp))
    }
}

data$sample_latency_us <- data$sample_latency * 5 / 1e3
# data$packet_latency_us <- data$packet_latency * 5 / 1e3

nrow(data[data$spp == 44,])
nrow(data[data$spp == 48,])
nrow(data[data$spp == 64,])
nrow(data[data$spp == 128,])
nrow(data[data$spp == 256,])

mean_sample_latency_us <- aggregate(sample_latency_us ~ spp, data = data, FUN = mean)
mean_sample_latency_us$sample_latency_us <- as.numeric(format(round(mean_sample_latency_us$sample_latency_us, 3), nsmall = 3))

pdf("spp_sample_latency_histograms.pdf",width=12,height=7)
ggplot(data,aes(sample_latency_us,fill=spp)) +
    # geom_density(alpha=0.2) +
    geom_histogram(binwidth=.01, alpha=.5, position="identity") +
    scale_x_continuous("Sample Latency (us)",breaks=mean_sample_latency_us$sample_latency_us) +
    ylab("Density Count") +
    # scale_y_log10("Density Count") +
    # scale_fill_grey() +
    # scale_fill_manual(values = c("LSTM Prediction Error     " = "white", "Naive Prediction Error     " = "#000000")) +
    theme_minimal() +
    # theme_bw() +
    theme(
        legend.position = "top",
        # legend.title = element_blank(),
        legend.key.width=unit(0.8,"cm"),
        legend.key.height=unit(0.8,"cm"),
        axis.text.x=element_text(size=12,angle=45,hjust=0.5,vjust=0.5),
        axis.text.y=element_text(size=12,angle=0,hjust=1),
        axis.title.x = element_text(size=12,angle=0,hjust=.5,vjust=0,face="plain"),
        axis.title.y = element_text(size=12,hjust=.5,vjust=.5,face="plain"),
        legend.text=element_text(size=16)
    )

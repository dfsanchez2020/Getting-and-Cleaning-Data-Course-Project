## Cree un script R llamado run_analysis.R que haga lo siguiente:
## 1. Fusiona los conjuntos de entrenamiento y prueba para crear un conjunto de datos.
## 2. Extrae solo las mediciones de la media y la desviación estándar para cada medición.
## 3. Utiliza nombres de actividades descriptivas para nombrar las actividades en el conjunto de datos
## 4. Etiqueta adecuadamente el conjunto de datos con nombres descriptivos de la actividad.
## 5. Crea un segundo conjunto de datos ordenado independiente con el promedio de cada variable para cada actividad y cada sujeto.

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Carga etiquetas de actividad
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Carga nombres de columna de datos
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extraiga solo las mediciones en la media y la desviación estándar para cada medición.
extract_features <- grepl("mean|std", features)

# Cargar y procesar datos X_test y y_test.
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(X_test) = features

# Extraiga solo las mediciones en la media y la desviación estándar para cada medición.
X_test = X_test[,extract_features]

# Cargar etiquetas de actividad
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Datos de enlace
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Cargar y procesar datos de X_train y y_train.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

# Extraiga solo las mediciones en la media y la desviación estándar para cada medición.
X_train = X_train[,extract_features]

# Cargar datos de actividad
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Datos de enlace
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# combinar test y train data
data = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Aplicar la función media al conjunto de datos usando la función dcast
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

# Descargando el tidy_set
write.table(tidy_data, file = "./tidy_data.txt")

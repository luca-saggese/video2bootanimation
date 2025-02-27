#!/bin/bash

# Funzione per mostrare l'help
function show_help() {
    echo "Utilizzo: $0 -i <video> -w <larghezza> -h <altezza> [-f <fps>] [-s <start_time>] [-e <end_time>] [-shutdown]"
    echo ""
    echo "Opzioni:"
    echo "  -i <video>        File video di input (obbligatorio)"
    echo "  -w <larghezza>    Larghezza della bootanimation (obbligatorio)"
    echo "  -h <altezza>      Altezza della bootanimation (obbligatorio)"
    echo "  -f <fps>          Frame per secondo (default: 30)"
    echo "  -s <start_time>   Tempo di inizio estrazione (formato: HH:MM:SS)"
    echo "  -e <end_time>     Tempo di fine estrazione (formato: HH:MM:SS)"
    echo "  -scale <pad|cover> Metodo di ridimensionamento (default: cover)"
    echo "  -shutdown         Crea anche shutdownanimation.zip con i frame al contrario"
    echo "  -help             Mostra questo messaggio"
    exit 0
}

# Valori di default
FPS=10
START_TIME=""
END_TIME=""
SCALE_METHOD="cover"

# Parsing degli argomenti
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i) VIDEO="$2"; shift 2 ;;
        -w) WIDTH="$2"; shift 2 ;;
        -h) HEIGHT="$2"; shift 2 ;;
        -f) FPS="$2"; shift 2 ;;
        -s) START_TIME="-ss $2"; shift 2 ;;
        -e) END_TIME="-to $2"; shift 2 ;;
        -scale) SCALE_METHOD="$2"; shift 2 ;;
        -shutdown) CREATE_SHUTDOWN=true; shift ;;
        -help) show_help ;;
        *) echo "Opzione sconosciuta: $1"; show_help ;;
    esac
done

# Controllo parametri obbligatori
if [[ -z "$VIDEO" || -z "$WIDTH" || -z "$HEIGHT" ]]; then
    echo "Errore: video, larghezza e altezza sono obbligatori."
    show_help
fi

# Definizione filtro di scaling
if [[ "$SCALE_METHOD" == "cover" ]]; then
    SCALE_FILTER="scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=increase,crop=$WIDTH:$HEIGHT"
elif [[ "$SCALE_METHOD" == "pad" ]]; then
    SCALE_FILTER="scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2"
else
    echo "Errore: opzione -scale deve essere 'pad' o 'cover'."
    exit 1
fi

# Definizione cartelle output
OUTPUT_DIR="bootanimation"
ZIP_FILE="bootanimation.zip"
AUDIO_FILE="boot.wav"
SHUTDOWN_DIR="shutdownanimation"
SHUTDOWN_ZIP="shutdownanimation.zip"

# Pulizia e creazione cartelle
rm -rf "$OUTPUT_DIR" "$SHUTDOWN_DIR"
mkdir -p "$OUTPUT_DIR/part0" "$OUTPUT_DIR/part1"
rm $ZIP_FILE $AUDIO_FILE $SHUTDOWN_ZIP

# Estrai i frame dal video per bootanimation
echo ffmpeg $START_TIME $END_TIME -i "$VIDEO" -vf "fps=$FPS,$SCALE_FILTER" "$OUTPUT_DIR/part0/%04d.png"
ffmpeg $START_TIME $END_TIME -i "$VIDEO" -vf "fps=$FPS,$SCALE_FILTER" "$OUTPUT_DIR/part0/%04d.png"

# Prendi l'ultimo frame e mettilo in part1 (animazione statica finale)
LAST_FRAME=$(ls -v "$OUTPUT_DIR/part0" | tail -n 1)
cp "$OUTPUT_DIR/part0/$LAST_FRAME" "$OUTPUT_DIR/part1/"

# Crea il file desc.txt per bootanimation
echo "$WIDTH $HEIGHT $FPS" > "$OUTPUT_DIR/desc.txt"
echo "p 1 0 part0" >> "$OUTPUT_DIR/desc.txt"
echo "p 0 0 part1" >> "$OUTPUT_DIR/desc.txt"

# Crea bootanimation.zip senza compressione
cd "$OUTPUT_DIR" || exit
zip -0 -r "../$ZIP_FILE" ./*
cd ..

# Estrai l'audio in boot.wav
ffmpeg $START_TIME $END_TIME -i "$VIDEO" -ac 2 -ar 44100 -vn "$AUDIO_FILE"

# Se richiesto, genera anche la shutdown animation con i frame invertiti
if [ "$CREATE_SHUTDOWN" = true ]; then
    mkdir -p "$SHUTDOWN_DIR/part0" "$SHUTDOWN_DIR/part1"

    # Copia i frame invertiti
    for FRAME in $(ls -v "$OUTPUT_DIR/part0" | tac); do
        cp "$OUTPUT_DIR/part0/$FRAME" "$SHUTDOWN_DIR/part0/"
    done

    # Copia l'ultimo frame di shutdown in part1
    LAST_SHUTDOWN_FRAME=$(ls -v "$SHUTDOWN_DIR/part0" | tail -n 1)
    cp "$SHUTDOWN_DIR/part0/$LAST_SHUTDOWN_FRAME" "$SHUTDOWN_DIR/part1/"

    # Crea il file desc.txt per shutdownanimation
    echo "$WIDTH $HEIGHT $FPS" > "$SHUTDOWN_DIR/desc.txt"
    echo "p 1 0 part0" >> "$SHUTDOWN_DIR/desc.txt"
    echo "p 0 0 part1" >> "$SHUTDOWN_DIR/desc.txt"

    # Crea shutdownanimation.zip senza compressione
    cd "$SHUTDOWN_DIR" || exit
    zip -0 -r "../$SHUTDOWN_ZIP" ./*
    cd ..

    echo "Shutdown animation creata: $SHUTDOWN_ZIP"
fi

# Pulizia (opzionale)
rm -rf "$OUTPUT_DIR" "$SHUTDOWN_DIR"

echo "Bootanimation creata: $ZIP_FILE"
echo "Audio estratto: $AUDIO_FILE"

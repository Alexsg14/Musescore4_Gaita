import QtQuick 2.2
import MuseScore 3.0

MuseScore {
    title: "Gaita — RE → DO"
    version: "0.1.0"
    description: "Convierte notación de gaita del sistema RE al sistema DO moviendo cada cabeza una posición diatónica, sin transposición cromática normal."
    menuPath: "Plugins.Gaita.RE → DO"
    categoryCode: "composing-arranging-tools"
    requiresScore: true

    // Dirección diatónica:
    // +1 = siguiente nombre de nota: C->D->E->F->G->A->B->C
    // -1 = anterior nombre de nota: C->B->A->G->F->E->D->C
    property int direction: 1

    // TPC naturales de MuseScore para C D E F G A B
    property var naturalTpc: [14, 16, 18, 13, 15, 17, 19]

    // Distancia cromática entre nombres naturales consecutivos:
    // C-D, D-E, E-F, F-G, G-A, A-B, B-C
    property var stepUp: [2, 2, 1, 2, 2, 2, 1]

    function positiveMod(a, b) {
        var r = a % b
        return r < 0 ? r + b : r
    }

    // Convierte un TPC (con o sin alteración) al nombre base:
    // 0=C, 1=D, 2=E, 3=F, 4=G, 5=A, 6=B.
    // Las alteraciones no cambian el resto módulo 7 del TPC.
    function letterFromTpc(tpc) {
        var r = positiveMod(tpc, 7)
        switch (r) {
        case 0: return 0 // C
        case 2: return 1 // D
        case 4: return 2 // E
        case 6: return 3 // F
        case 1: return 4 // G
        case 3: return 5 // A
        case 5: return 6 // B
        }
        return -1
    }

    // Alteración que impone la armadura actual a un nombre de nota.
    // keySig: número de sostenidos (>0) o bemoles (<0).
    function keyAlteration(letter, keySig) {
        var sharps = [3, 0, 4, 1, 5, 2, 6] // F C G D A E B
        var flats  = [6, 2, 5, 1, 4, 0, 3] // B E A D G C F
        var i

        if (keySig > 0) {
            for (i = 0; i < keySig && i < 7; ++i) {
                if (sharps[i] === letter)
                    return 1
            }
        } else if (keySig < 0) {
            for (i = 0; i < -keySig && i < 7; ++i) {
                if (flats[i] === letter)
                    return -1
            }
        }
        return 0
    }

    function tpcAlteration(tpc, letter) {
        var d = tpc - naturalTpc[letter]
        if (d % 7 !== 0)
            return 99
        return d / 7
    }

    function targetLetter(sourceLetter) {
        return positiveMod(sourceLetter + direction, 7)
    }

    function chromaticDelta(sourceLetter, targetLetterValue, keySig) {
        var sourceAlt = keyAlteration(sourceLetter, keySig)
        var targetAlt = keyAlteration(targetLetterValue, keySig)

        if (direction > 0) {
            return stepUp[sourceLetter] + targetAlt - sourceAlt
        }

        // Al bajar, usamos la distancia del nombre anterior al actual.
        return -stepUp[targetLetterValue] + targetAlt - sourceAlt
    }

    function setTargetTpc(note, targetTpcValue, oldTpc1, oldTpc2, currentTpc) {
        // tpc1 = afinación de concierto; tpc2 = afinación escrita.
        // Conservamos la relación existente por si el instrumento de MuseScore
        // está configurado como transpositor.
        var deltaTpc = oldTpc2 - oldTpc1

        if (deltaTpc === 0) {
            note.tpc1 = targetTpcValue
            note.tpc2 = targetTpcValue
        } else if (currentTpc === oldTpc2) {
            note.tpc2 = targetTpcValue
            note.tpc1 = targetTpcValue - deltaTpc
        } else {
            note.tpc1 = targetTpcValue
            note.tpc2 = targetTpcValue + deltaTpc
        }
    }

    function convertNote(note, keySig) {
        if (!note)
            return 0

        // Si hay una alteración explícita escrita junto a la nota,
        // no adivinamos su equivalencia.
        if (note.accidental)
            return -1

        // Guardamos el estado tonal antes de modificar pitch, porque MuseScore
        // puede recalcular algunas propiedades al cambiar la altura MIDI.
        var oldTpc1 = note.tpc1
        var oldTpc2 = note.tpc2
        var sourceTpc = note.tpc
        var sourceLetter = letterFromTpc(sourceTpc)
        if (sourceLetter < 0)
            return -1

        // Si el TPC no coincide con lo que dicta la armadura, la nota está
        // cromáticamente alterada aunque no podamos identificar el símbolo.
        // La dejamos intacta.
        var expectedAlt = keyAlteration(sourceLetter, keySig)
        var actualAlt = tpcAlteration(sourceTpc, sourceLetter)
        if (actualAlt !== expectedAlt)
            return -1

        var destLetter = targetLetter(sourceLetter)
        var destAlt = keyAlteration(destLetter, keySig)
        var destTpc = naturalTpc[destLetter] + 7 * destAlt
        var delta = chromaticDelta(sourceLetter, destLetter, keySig)
        var newPitch = note.pitch + delta

        if (newPitch < 0 || newPitch > 127)
            return -1

        note.pitch = newPitch
        setTargetTpc(note, destTpc, oldTpc1, oldTpc2, sourceTpc)
        return 1
    }

    function convertNotes(notes, keySig) {
        var changed = 0
        var skipped = 0
        for (var i = 0; i < notes.length; ++i) {
            var result = convertNote(notes[i], keySig)
            if (result > 0)
                ++changed
            else if (result < 0)
                ++skipped
        }
        return [changed, skipped]
    }

    function convertChord(chord, keySig) {
        var changed = 0
        var skipped = 0
        var result
        var i

        // Adornos / apoyaturas
        var grace = chord.graceNotes
        if (grace && grace.length > 0) {
            for (i = 0; i < grace.length; ++i) {
                result = convertNotes(grace[i].notes, keySig)
                changed += result[0]
                skipped += result[1]
            }
        }

        // Acorde principal
        result = convertNotes(chord.notes, keySig)
        changed += result[0]
        skipped += result[1]

        return [changed, skipped]
    }

    function runConversion() {
        var cursor = curScore.newCursor()
        var startStaff
        var endStaff
        var endTick
        var fullScore = false
        var totalChanged = 0
        var totalSkipped = 0

        cursor.rewind(Cursor.SELECTION_START)

        if (!cursor.segment) {
            fullScore = true
            startStaff = 0
            endStaff = curScore.nstaves - 1
        } else {
            startStaff = cursor.staffIdx
            cursor.rewind(Cursor.SELECTION_END)

            if (cursor.tick === 0)
                endTick = curScore.lastSegment.tick + 1
            else
                endTick = cursor.tick

            endStaff = cursor.staffIdx
        }

        curScore.startCmd()

        for (var staff = startStaff; staff <= endStaff; ++staff) {
            for (var voice = 0; voice < 4; ++voice) {
                cursor.rewind(Cursor.SELECTION_START)
                cursor.voice = voice
                cursor.staffIdx = staff

                if (fullScore)
                    cursor.rewind(Cursor.SCORE_START)

                while (cursor.segment && (fullScore || cursor.tick < endTick)) {
                    if (cursor.element && cursor.element.type === Element.CHORD) {
                        var result = convertChord(cursor.element, cursor.keySignature)
                        totalChanged += result[0]
                        totalSkipped += result[1]
                    }
                    cursor.next()
                }
            }
        }

        curScore.endCmd()

        console.log("Gaita RE→DO: " + totalChanged +
                    " notas convertidas; " + totalSkipped +
                    " notas alteradas omitidas.")
    }

    onRun: {
        runConversion()
        ;(typeof(quit) === "undefined" ? Qt.quit : quit)()
    }
}

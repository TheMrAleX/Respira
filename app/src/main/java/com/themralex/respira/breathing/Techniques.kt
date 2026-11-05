package com.themralex.respira.breathing

enum class Phase { INHALA, SORBO, SOSTEN, EXHALA, SOSTEN_VACIO }

data class PhaseSegment(val phase: Phase, val seconds: Int)

data class Technique(
    val id: String,
    val name: String,
    val description: String,
    val segments: List<PhaseSegment>,
    val cycleSeconds: Int,
    val unlockLevel: Int = 1,
)

val TechniqueCatalog: List<Technique> = listOf(
    Technique(
        id = "coherencia",
        name = "Coherencia",
        description = "Inhala 5, exhala 5. Equilibrio simple.",
        segments = listOf(
            PhaseSegment(Phase.INHALA, 5),
            PhaseSegment(Phase.EXHALA, 5),
        ),
        cycleSeconds = 10,
    ),
    Technique(
        id = "exhalacion",
        name = "Exhalación larga",
        description = "Inhala 4, exhala 6. Para calmar.",
        segments = listOf(
            PhaseSegment(Phase.INHALA, 4),
            PhaseSegment(Phase.EXHALA, 6),
        ),
        cycleSeconds = 10,
    ),
    Technique(
        id = "pausa",
        name = "Con pausa",
        description = "Inhala 4, sostén 2, exhala 6.",
        segments = listOf(
            PhaseSegment(Phase.INHALA, 4),
            PhaseSegment(Phase.SOSTEN, 2),
            PhaseSegment(Phase.EXHALA, 6),
        ),
        cycleSeconds = 12,
    ),
    Technique(
        id = "suspiro",
        name = "Suspiro",
        description = "Inhala 2, sorbo 1, exhala 6.",
        segments = listOf(
            PhaseSegment(Phase.INHALA, 2),
            PhaseSegment(Phase.SORBO, 1),
            PhaseSegment(Phase.EXHALA, 6),
        ),
        cycleSeconds = 9,
    ),
    Technique(
        id = "dormir",
        name = "Para dormir",
        description = "Inhala 4, exhala 8. Muy lento.",
        segments = listOf(
            PhaseSegment(Phase.INHALA, 4),
            PhaseSegment(Phase.EXHALA, 8),
        ),
        cycleSeconds = 12,
    ),
    Technique(
        id = "cuadrada",
        name = "Cuadrada",
        description = "4-4-4-4. Para practicar con calma.",
        segments = listOf(
            PhaseSegment(Phase.INHALA, 4),
            PhaseSegment(Phase.SOSTEN, 4),
            PhaseSegment(Phase.EXHALA, 4),
            PhaseSegment(Phase.SOSTEN_VACIO, 4),
        ),
        cycleSeconds = 16,
        unlockLevel = 3,
    ),
)

fun techniqueById(id: String): Technique? = TechniqueCatalog.firstOrNull { it.id == id }

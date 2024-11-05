## Parametri dei minigiochi
- `n_start`: numero iniziale della linea dei numeri
- `n_end`: numero finale della linea dei numeri
- `n_numbers`: quanti numeri conterrà la linea dei numeri?
- `filled`: percentuale (valore tra 0 e 1) di iniziale riempimento della linea
- `range_random`: range da cui estrarre i numeri _rumorosi_ di riempimento piscina
- `ascendent`: _bool_ che definisce se la linea di numeri sarà **ascendente** o **discendente**
- `shift`: tutta la linea viene shiftata di un numero in `[-shift, shift]`.
NON ANCORA COMPATIBILE CON `num_ok` E `num_ko`: USARE SEMPRE = 0
- `num_ok`: quante copie di un _numero **ok**_ ci sono sepolte?
- `num_ko`: quante copie di un _numero **ko**_ ci sono sepolte?
- `total_blocks`: quanti bocchi sono sepolti in totale?
- `game_type`: indicazione circa il tipo di gioco
- `portal_type`: tipo di portale

# Un esempio...
```json
{
	"n_start": 1,
	"n_end": 10,
	"n_numbers": 6,
	"filled": 0.5,
	"range_random": [1, 20],
	"ascendent": true,
	"shift": 0,
	"num_ok": 6,
	"num_ko": 4,
	"total_blocks": 150,
	"game_type": "DigNumbers",
	"portal_type": "standard"
}
```

Con questi parametri una possibile **linea di numeri** è

	[1] < [ ] < [5] < [ ] < [ ] < [10]

### **ok**
Indichiamo con **ok** una lista di numeri _minimale_ e _sufficiente_ per la soluzione, ad esempio

- **ok** = `[2, 6, 7]`, oppure

- **ok** = `[4, 6, 9]`, oppure

- **ok** = `[3, 7, 8]`, eccetera

Ma NON
- **ok** = `[2, 3, 6]` perché non sarebbe una _soluzione_
- **ok** = `[2, 3, 6, 7]` perché non sarebbe _minimale_

Nel codice ne viene generato una lista random tra quelle possibili per **ok**.

### **ko**
Indichiamo con **ko** la lista dei numeri già presenti nella linea.
Nell'esempio si avrebbe

**ko** = `[1, 5, 10]`

## Riempimento
Il numero di blocchi presenti nell'arena (o nella piscina) è in numero di `total_blocks`.
Deve essere premura di chi sceglie i parametri che

	num_ok * len(ok) + num_ko * len(ko) <= total_blocks

Nel caso si trattasse di un < stretto, come riempiamo il resto della piscina (arena)? Qui entra in gioco `range_random`.

### **rand**

detti **x** ed **y** gli estremi di `range_random`, è importante che

	x < n_start < n_end < y

Infatti si costruisce, nel codice, una lista, detta  **rand** come

**rand** = `[x, ..., n_start-1] + [n_end+1, ..., y]`

da questa verranno estratte (come spiegato dalla riga di codice poco più in basso) i numeri a riempire la piscina
(arena).

Detto **m** il numero di blocchi mancanti al riempimento della piscina (arena),
questa riga di pseudo-codice spiega bene come vengono usati alcuni parametri:

**numbers_list** = `num_ko` * **ok** + `num_ko` * **ko** + [**rand**[i % len(**rand**)] for i in range(**m**)]

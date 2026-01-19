/**
 * Mock-Daten für Development
 * Wird verwendet wenn DB nicht verfügbar
 */

export const mockMitarbeiter = [
  {
    ID: 707,
    Nachname: 'Alali',
    Vorname: 'Ahmad',
    Strasse: 'Nürnberger Str.',
    Nr: '123',
    PLZ: '90478',
    Ort: 'Nürnberg',
    Land: 'Deutschland',
    Bundesland: 'BY',
    Tel_Mobil: '0176 / 123 456 78',
    Tel_Festnetz: '0911 / 9876 543',
    Email: 'ahmad.alali@example.com',
    Geschlecht: 1, // männlich
    Staatsang: 'Syrisch',
    Geb_Dat: new Date('1991-01-01'),
    Geb_Ort: 'Damaskus',
    Eintrittsdatum: new Date('2023-10-02'),
    Austrittsdatum: null,
    IstAktiv: true,
    IstSubunternehmer: false,
    Anstellungsart_ID: 3,
    LEXWare_ID: null,
  },
  {
    ID: 708,
    Nachname: 'Müller',
    Vorname: 'Thomas',
    Strasse: 'Hauptstr.',
    Nr: '45',
    PLZ: '90402',
    Ort: 'Nürnberg',
    Land: 'Deutschland',
    Bundesland: 'BY',
    Tel_Mobil: '0176 / 987 654 32',
    Tel_Festnetz: '',
    Email: 'thomas.mueller@example.com',
    Geschlecht: 1,
    Staatsang: 'Deutsch',
    Geb_Dat: new Date('1985-05-15'),
    Geb_Ort: 'Nürnberg',
    Eintrittsdatum: new Date('2020-01-15'),
    Austrittsdatum: null,
    IstAktiv: true,
    IstSubunternehmer: false,
    Anstellungsart_ID: 3,
    LEXWare_ID: 123,
  },
  {
    ID: 709,
    Nachname: 'Schmidt',
    Vorname: 'Anna',
    Strasse: 'Bahnhofstr.',
    Nr: '7',
    PLZ: '90443',
    Ort: 'Nürnberg',
    Land: 'Deutschland',
    Bundesland: 'BY',
    Tel_Mobil: '0151 / 234 567 89',
    Tel_Festnetz: '',
    Email: 'anna.schmidt@example.com',
    Geschlecht: 2, // weiblich
    Staatsang: 'Deutsch',
    Geb_Dat: new Date('1992-08-22'),
    Geb_Ort: 'Fürth',
    Eintrittsdatum: new Date('2021-03-01'),
    Austrittsdatum: null,
    IstAktiv: true,
    IstSubunternehmer: false,
    Anstellungsart_ID: 4,
    LEXWare_ID: 124,
  },
];

let nextId = 710;

/**
 * Mock-Mitarbeiter-Model
 */
export const MockMitarbeiter = {
  getAllMitarbeiter: async () => {
    return mockMitarbeiter.filter(m => m.IstAktiv);
  },

  getMitarbeiterById: async (id) => {
    return mockMitarbeiter.find(m => m.ID === id) || null;
  },

  createMitarbeiter: async (data) => {
    const newMitarbeiter = {
      ID: nextId++,
      ...data,
      Eintrittsdatum: data.Eintrittsdatum || new Date(),
      IstAktiv: data.IstAktiv !== undefined ? data.IstAktiv : true,
    };
    mockMitarbeiter.push(newMitarbeiter);
    return newMitarbeiter;
  },

  updateMitarbeiter: async (id, data) => {
    const index = mockMitarbeiter.findIndex(m => m.ID === id);
    if (index === -1) return null;
    mockMitarbeiter[index] = { ...mockMitarbeiter[index], ...data };
    return mockMitarbeiter[index];
  },

  deleteMitarbeiter: async (id) => {
    const index = mockMitarbeiter.findIndex(m => m.ID === id);
    if (index === -1) return false;
    mockMitarbeiter.splice(index, 1);
    return true;
  },
};

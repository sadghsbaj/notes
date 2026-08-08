import { randomString } from "$utils/_system";

export interface Note {
    id: string;
    title: string;
    content: string;
}

const STORAGE_KEY = "notes-storage";
const ACTIVE_NOTE_KEY = "notes-active-id";
const DEBOUNCE_DELAY = 300;

export class Editor {
    #notes: Note[] = $state([]);
    #activeNote: Note | undefined = $state(undefined);

    #lastSavedState: string = $state("");
    #isDirty: boolean = $derived(JSON.stringify(this.#notes) !== this.#lastSavedState);

    #saveTimer: ReturnType<typeof setTimeout> | undefined = undefined;

    constructor() {
        this.loadFromStorage();
    }

    get notes(): readonly Note[] {
        return this.#notes;
    }

    get activeNote(): Note | undefined {
        return this.#activeNote;
    }

    get isDirty(): boolean {
        return this.#isDirty;
    }

    updateActiveNote(fields: Partial<Pick<Note, "title" | "content">>): void {
        if (!this.#activeNote) return;

        const note = this.#notes.find((n) => n.id === this.#activeNote?.id);
        if (!note) return;

        if (fields.title !== undefined) note.title = fields.title;
        if (fields.content !== undefined) note.content = fields.content;

        this.triggerDebounceSave();
    }

    addTab(): void {
        const id = randomString(16);
        const newTab = { id, title: "Neu", content: "" };

        this.#notes.push(newTab);
        this.setActiveNote(id);
        this.saveImmediately();
    }

    removeTab(id: Note["id"]): void {
        const index = this.#notes.findIndex((note) => note.id === id);
        if (index === -1) return;

        const isActiveTab = this.#activeNote?.id === id;

        this.#notes = this.#notes.filter((note) => note.id !== id);

        if (isActiveTab) {
            if (this.#notes.length === 0) {
                this.setActiveNote(undefined);
            } else {
                const newIndex = index >= this.#notes.length ? this.#notes.length - 1 : index;
                this.setActiveNote(this.#notes[newIndex].id);
            }
        }

        this.saveImmediately();
    }

    setActiveNote(id: Note["id"] | undefined): void {
        if (this.#isDirty) {
            this.saveImmediately();
        }

        if (!id) {
            this.#activeNote = undefined;
            localStorage.removeItem(ACTIVE_NOTE_KEY);
            return;
        }

        this.#activeNote = this.#notes.find((note) => note.id === id);

        if (this.#activeNote) {
            localStorage.setItem(ACTIVE_NOTE_KEY, id);
        }
    }

    private triggerDebounceSave(): void {
        clearTimeout(this.#saveTimer);
        this.#saveTimer = setTimeout(() => {
            this.saveToStorage();
        }, DEBOUNCE_DELAY);
    }

    private saveImmediately(): void {
        clearTimeout(this.#saveTimer);
        this.saveToStorage();
    }

    private saveToStorage(): void {
        try {
            const dataToSave = JSON.stringify(this.#notes);
            localStorage.setItem(STORAGE_KEY, dataToSave);

            if (this.#activeNote) {
                localStorage.setItem(ACTIVE_NOTE_KEY, this.#activeNote.id);
            } else {
                localStorage.removeItem(ACTIVE_NOTE_KEY);
            }

            this.#lastSavedState = dataToSave;
        } catch (error) {
            console.warn(error);
        }
    }

    private loadFromStorage(): void {
        try {
            const savedTabs = localStorage.getItem(STORAGE_KEY);

            if (!savedTabs) {
                this.addTab();
                return;
            }

            const savedActiveId = localStorage.getItem(ACTIVE_NOTE_KEY);

            this.#notes = JSON.parse(savedTabs);

            const activeExists = this.#notes.some((note) => note.id === savedActiveId);

            this.#activeNote =
                savedActiveId && activeExists
                    ? this.#notes.find((note) => note.id === savedActiveId)
                    : (this.#notes[0] ?? undefined);

            this.#lastSavedState = JSON.stringify(this.#notes);
        } catch (error) {
            console.warn(error);
        }
    }
}

export const editorState = new Editor();

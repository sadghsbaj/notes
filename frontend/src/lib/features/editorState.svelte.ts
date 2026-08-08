import { randomString } from "$utils/_system";

export interface Note {
    id: string;
    title: string;
    content: string;
}

const STORAGE_KEY = "notes-storage";
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
            // No notes left -> no active
            if (this.#notes.length === 0) {
                this.#activeNote = undefined;
            } else {
                // If it was the last element, the element at index - 1 moves up.
                // Otherwise, the element at 'index' moves up (which was previously index + 1).
                const newIndex = index >= this.#notes.length ? this.#notes.length - 1 : index;
                this.#activeNote = this.#notes[newIndex];
            }
        }

        this.saveImmediately();
    }

    setActiveNote(id: Note["id"]): void {
        if (this.#isDirty) {
            this.saveImmediately();
        }
        this.#activeNote = this.#notes.find((note) => note.id === id);
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

            this.#notes = JSON.parse(savedTabs);
            this.#activeNote = this.#notes[0];
            this.#lastSavedState = JSON.stringify(this.#notes);
        } catch (error) {
            console.warn(error);
        }
    }
}

export const editorState = new Editor();

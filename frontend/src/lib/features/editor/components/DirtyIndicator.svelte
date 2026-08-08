<script lang="ts">
    import { editorState } from "$features/editorState.svelte";
</script>

<div
    class="border rounded-full h-4 w-4 bottom-4 right-4 fixed {editorState.isDirty
        ? 'border-warning-500 bg-warning-200'
        : 'border-success-500 bg-success-200'}"
></div>

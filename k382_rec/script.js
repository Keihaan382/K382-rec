let isVisible = false;

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === "open") {
        document.body.style.display = 'block';
        isVisible = true;
    } else if (data.action === "close") {
        document.body.style.display = 'none';
        isVisible = false;
    }
});

document.addEventListener('DOMContentLoaded', function() {
    // Ocultar la UI al inicio
    document.body.style.display = 'none';

    // Inicializar elementos
    const container = document.querySelector('.container');
    const recordToggle = document.getElementById('recordToggle');
    
    // Manejar el toggle de grabación
    recordToggle.addEventListener('change', function() {
        if (!isVisible) return;
        
        if (this.checked) {
            fetch(`https://${GetParentResourceName()}/startRec`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            });
        } else {
            fetch(`https://${GetParentResourceName()}/stopRec`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            });
        }
    });

    // Configuración del arrastre
    let isDragging = false;
    let currentX;
    let currentY;
    let initialX;
    let initialY;
    let xOffset = 0;
    let yOffset = 0;

    container.addEventListener('mousedown', dragStart);
    document.addEventListener('mousemove', drag);
    document.addEventListener('mouseup', dragEnd);

    function dragStart(e) {
        if (e.target.closest('.toggle-container')) return;

        initialX = e.clientX - xOffset;
        initialY = e.clientY - yOffset;

        if (e.target === container || container.contains(e.target)) {
            isDragging = true;
        }
    }

    function drag(e) {
        if (isDragging) {
            e.preventDefault();
            
            currentX = e.clientX - initialX;
            currentY = e.clientY - initialY;

            xOffset = currentX;
            yOffset = currentY;

            setTranslate(currentX, currentY, container);
        }
    }

    function dragEnd(e) {
        initialX = currentX;
        initialY = currentY;
        isDragging = false;
    }

    function setTranslate(xPos, yPos, el) {
        el.style.transform = `translate(${xPos}px, ${yPos}px)`;
    }
});
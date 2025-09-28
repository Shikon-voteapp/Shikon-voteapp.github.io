// 現在の年を自動設定
document.addEventListener('DOMContentLoaded', function() {
  const yearElements = document.querySelectorAll('#year');
  const currentYear = new Date().getFullYear();
  
  yearElements.forEach(element => {
    element.textContent = currentYear;
  });
});

// スムーススクロール
document.addEventListener('DOMContentLoaded', function() {
  const links = document.querySelectorAll('a[href^="#"]');
  
  links.forEach(link => {
    link.addEventListener('click', function(e) {
      e.preventDefault();
      
      const targetId = this.getAttribute('href').substring(1);
      const targetElement = document.getElementById(targetId);
      
      if (targetElement) {
        targetElement.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    });
  });
});

// ダークモード対応
function updateColorScheme() {
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  document.documentElement.setAttribute('data-theme', prefersDark ? 'dark' : 'light');
}

// コードブロックのコピー機能
function addCopyButtons() {
  const codeBlocks = document.querySelectorAll('pre code');
  
  codeBlocks.forEach(block => {
    const pre = block.parentElement;
    if (pre.querySelector('.copy-btn')) return; // 既にボタンがある場合はスキップ
    
    const wrapper = document.createElement('div');
    wrapper.className = 'code-block';
    
    const copyBtn = document.createElement('button');
    copyBtn.className = 'copy-btn';
    copyBtn.textContent = 'コピー';
    
    copyBtn.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(block.textContent);
        copyBtn.textContent = 'コピー済み';
        copyBtn.classList.add('copied');
        
        setTimeout(() => {
          copyBtn.textContent = 'コピー';
          copyBtn.classList.remove('copied');
        }, 2000);
      } catch (err) {
        console.error('コピーに失敗しました:', err);
        copyBtn.textContent = 'エラー';
        setTimeout(() => {
          copyBtn.textContent = 'コピー';
        }, 2000);
      }
    });
    
    pre.parentNode.insertBefore(wrapper, pre);
    wrapper.appendChild(pre);
    wrapper.appendChild(copyBtn);
  });
}

// 初期化
document.addEventListener('DOMContentLoaded', function() {
  updateColorScheme();
  addCopyButtons();
  
  // カラースキームの変更を監視
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', updateColorScheme);
});

use std::{fs::OpenOptions, time::{self, Duration}};

use anyhow::anyhow;
use tiberius::{Client, Config, AuthMethod, time::time::PrimitiveDateTime};
use tokio::{net::TcpStream, task};
use tokio_util::compat::TokioAsyncWriteCompatExt;
use tracing::{info, debug};

#[tokio::main]
async fn main() {
    configure_log();
    
    let dump_clerk_data_to_csv_task = task::spawn(async {
        let csv_file = OpenOptions::new()
            .write(true)
            .append(true)
            .open("/Users/pportnoy/Repos/sqlserver-memory-clerks/memclerks.csv")
            .unwrap();
        let mut csv_file_writer = csv::Writer::from_writer(csv_file);
        let mut interval = tokio::time::interval(Duration::from_millis(500));

        let mut append_counter = 0_i32;
        loop {
            interval.tick().await;
            let clerks_data = gather_memory_clerk_data().await.unwrap();
            for clerk in clerks_data {
                let _ = csv_file_writer.write_record(&[clerk.2.to_string(), clerk.0.to_string(), clerk.1.to_string()]);
            }
            let _ = csv_file_writer.flush();
            append_counter += 1;

            // 120 appends at 500 ms = 2 minutes
            if append_counter > 240 {
                break;
            }
        }
    });

    let _ = dump_clerk_data_to_csv_task.await;
    
    info!("Completed execution.");
}

async fn gather_memory_clerk_data() -> anyhow::Result<Vec<(String, i64, PrimitiveDateTime)>> {
    debug!("Starting connection...");
    let mut db_config = Config::new();
    db_config.host("localhost");
    db_config.port(1433);
    db_config.authentication(AuthMethod::sql_server("sa", "Memory@Clerks"));
    db_config.trust_cert();
    debug!("Attempting to start a TCP stream to {}", db_config.get_addr());
    let tcp = TcpStream::connect(db_config.get_addr())
        .await
        .map_err(|err| anyhow!("Error establishing TCP Stream Conection: {:?}", err))?;
    tcp.set_nodelay(true)?;
    debug!("Attempting to connect a SQL Client");
    let mut client = Client::connect(db_config, tcp.compat_write()).await?;
    debug!("Connected the SQL Client!");
    let memory_clerks_result = client.query("SELECT
        [type],
        SUM(pages_kb) AS pages_kb,
        GETDATE() as datetime
    FROM
        sys.dm_os_memory_clerks WITH (NOLOCK)
    GROUP BY 
        [type]
    ORDER BY
        pages_kb DESC", &[]).await?;
    let rows = memory_clerks_result.into_results().await?;
    let mut results: Vec<(String, i64, PrimitiveDateTime)> = Vec::new();
    for row in &rows[0] {
        let memory_clerk_type = row.get(0).map(|t: &str| t.to_string()).unwrap();
        let pages_kb: i64 = row.get(1).unwrap();
        let date_time: PrimitiveDateTime = row.get(2).unwrap();
        results.push((memory_clerk_type, pages_kb, date_time));
    }
    Ok(results)
}

fn configure_log() {
    tracing_subscriber::fmt()
        .with_thread_ids(true)
        .with_thread_names(true)
        .with_max_level(tracing::Level::DEBUG)
        .with_target(false)
        .init();
}

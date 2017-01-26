PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

*/5 *   * * *   root       xivo-check-dahdi-ports
*/5 *   * * *   root       xivo-check-long-calls
0   */3 * * *   postgres   xivo-strip-queue-info 10800 > /dev/null
